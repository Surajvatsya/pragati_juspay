{-# LANGUAGE BangPatterns      #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-incomplete-record-updates #-}

module PragatiServer where


-- module MettleServer
--   ( startServer
--   , pragatiExceptionResponse
--   ) where

import qualified Data.Aeson                     as Aeson
import qualified Data.ByteString.Char8          as BS
import qualified Data.ByteString.UTF8           as BSU
import           Data.Default
import qualified Data.UUID                      as UUID
import qualified Data.UUID.V4                   as DUUID
import qualified Data.Vault.Lazy                as V
import qualified EulerHS.Interpreters           as I
import qualified EulerHS.Language               as L
import           EulerHS.Prelude
import qualified EulerHS.Runtime                as R
import qualified EulerHS.Types                  as T
import           Server              as Mettle
import           Storage.Queries.Config                 as Config
import qualified Storage.Beam.Utils as SBU
-- import           Mettle.Constants.APIErrorCode  (internalServerErr)
-- import qualified Mettle.Types.Engineering       as App
import qualified Storage.Queries.FlowMonad as App
-- import qualified Mettle.Utils.DB.Accessor as A
import qualified Storage.Queries.PostgresConfig as DB
-- import qualified Mettle.Utils.DB.RedisConfig    as KV
-- import           Mettle.Utils.Logger.Logger as Logger
-- import           Control.Monad.Trans.AWS        (Region (Mumbai, Singapore))
import qualified Data.HashMap.Strict            as Map
import qualified Data.Text                      as T
-- import           Mettle.Services.AWS.KMS        (decryptKMS)
import           Storage.Beam.Utils            as GUtils (forkIOWithUnmaskLabel)
import           Network.Connection             (TLSSettings (settingDisableCertificateValidation))
import qualified Network.HTTP.Client            as Client
import qualified Network.HTTP.Client.TLS        as CTLS
import qualified Network.HTTP.Types             as H
import           Network.Wai
import           Network.Wai.Handler.Warp       (Settings, defaultSettings,
                                                 runSettings, setFork,
                                                 setOnExceptionResponse,
                                                 setPort)
import           Network.Wai.Handler.WarpTLS
import           Servant                        (ServerError (errBody, errHTTPCode, errHeaders, errReasonPhrase))
import qualified System.Directory               as SD
import qualified System.Environment             as SE
import qualified Data.HashMap.Strict            as Map
import qualified System.Directory               as SD
import qualified System.Environment             as SE
import Mettle.APIErrorCode
-- import qualified Network.HTTP.Client.TLS        as CTLS

startServer :: IO ()
startServer = do
  port <- fromMaybe 8088 . (>>= readMaybe) <$> SE.lookupEnv "PORT"
  putStrLn @String "pragatiflow -> Awekening Pragati"
  awakenPragati port $ setPort port  setOnExceptionResponse
    pragatiExceptionResponse
    defaultSettings

awakenPragati :: Int -> Settings -> IO ()
awakenPragati port settings = do
  -- reqHeadersKey <- V.newKey
  -- loggerCfg     <- getLoggingConfigurations
  -- let formatter = T.defaultFlowFormatter
  -- putStrLn @String "mettleflow -> Igniting Mettle"
  -- print ("using KMS_REGION : " <> Config.getKMSRegion)
  config <- L.runIo Config.config'
  R.withFlowRuntime (Just R.createVoidLoggerRuntime)
    $ (\config2 flowRt' -> do
        putStrLn @String "Initializing DB and KV Connections..."
        let loggerRuntime = R._loggerRuntime $ R._coreRuntime flowRt'
            -- isMaskingEnabled = True
        mettleConfig <- I.runFlow flowRt' config2
        let prepare = do
              -- Logger.logGenericDebugM True loggerRuntime "Server config" mettleConfig
              -- if mettleConfig ^. A.isClusterRedisEnabled
              --   then
              --     DB.prepareDBConnections mettleConfig loggerRuntime :: L.Flow ()
              --      -- /*> KV.prepareClusterRedisConnections mettleConfig loggerRuntime) :: L.Flow ()
              --   else
              DB.prepareDBConnections mettleConfig loggerRuntime :: L.Flow ()
                -- *> KV.prepareRedisConnections mettleConfig loggerRuntime) :: L.Flow ()
        try (I.runFlow flowRt' prepare) >>= \case
          Left (e :: SomeException) ->
            putStrLn @String ("Exception thrown: " <> show e)
          Right _pubSubConnection -> do
            putStrLn @String
              ("Runtime created. Starting server at port " <> show port)
            !isTls <- fromMaybe False . (>>= readMaybe) <$> SE.lookupEnv
              "IS_TLS_ENABLED"
            !_isRedisStreamsEnabled <-
              fromMaybe False . (>>= readMaybe) <$> SE.lookupEnv
                "USE_REDIS_STREAMS"
            let !respTime = Client.responseTimeoutMicro 55000000 -- 55 secs
                !mSetting =
                  (CTLS.mkManagerSettings
                      (def { settingDisableCertificateValidation = True })
                      Nothing
                    )
                    { Client.managerResponseTimeout = respTime
                    }

            !manager     <- Client.newManager mSetting -- default HTTP manager

            !useProxy <- fromMaybe False . (>>= readMaybe) <$> SE.lookupEnv "USE_OUTGOING_PROXY"
            !proxyHost <- maybe "127.0.0.1" BSU.fromString <$> SE.lookupEnv "HTTP_PROXY_HOST"
            !proxyPort <- fromMaybe 8092 . (>>= readMaybe) <$> SE.lookupEnv "HTTP_PROXY_PORT"
            let !proxy = Client.useProxy (Client.Proxy proxyHost proxyPort)
            !mProxySetting <-
              if useProxy
                then do
                  putStrLn @String
                    ("Proxy configuration: USE_OUTGOING_PROXY=" <> show useProxy <>
                    ", HTTP_PROXY_HOST=" <> show proxyHost <>
                    ", HTTP_PROXY_PORT=" <> show proxyPort)
                  return $ Client.managerSetProxy proxy mSetting
                else do
                  putStrLn @String "!!! No proxy configuration provided"
                  return mSetting
            !managerProxy <- Client.newManager mProxySetting
            let !clientManager = Map.insert "mProxy" managerProxy Map.empty

            _pendingReq  <- newTVarIO []
            !channelName <- UUID.toASCIIBytes <$> DUUID.nextRandom
            print ("Node channel name: " <> channelName)
            let flowRt = flowRt' { R._defaultHttpClientManager = manager
                                 , R._httpClientManagers = clientManager
                                 }
            let env    = App.AppState mettleConfig flowRt channelName
            let
              r f =
                f
                    (setFork (\x -> void $ forkIOWithUnmaskLabel "server" x)
                             settings
                    )
                  -- $ Mettle.run reqHeadersKey env
                  $ Mettle.run reqHeadersKey env
            if isTls
              then do
                certFile <- SE.getEnv "CERT_PATH"
                keyFile  <- SE.getEnv "KEY_PATH"
                let tlsOpts = tlsSettings certFile keyFile
                r (runTLS tlsOpts)
              else r runSettings
      )
        (pure config)

pragatiExceptionResponse :: SomeException -> Response
pragatiExceptionResponse exception = do
  let anyException = fromException exception
  case anyException of
    Just ex -> responseLBS
      (H.Status (errHTTPCode ex) (BS.pack $ errReasonPhrase ex))
      ((H.hContentType, "application/json") : errHeaders ex)
      (errBody ex)
    Nothing -> responseLBS H.status200
                           [(H.hContentType, "application/json")]
                           (Aeson.encode internalServerErr)
-- forkIOWithUnmaskLabel :: String -> ((forall a. IO a -> IO a) -> IO ()) -> IO ThreadId
-- forkIOWithUnmaskLabel label f = do
--   tid <- forkIOWithUnmask f
--   labelThread tid label
--   return tid

-- getLoggingConfigurations :: IO T.LoggerConfig
-- getLoggingConfigurations = do
--   logFilePath <- SE.lookupEnv "LOG_FILE"
--   logFile     <- case logFilePath of
--     Just path -> return path
--     Nothing   -> do
--       _dir <- SD.createDirectoryIfMissing True "app/logs/"
--       return "app/logs/app.log"
--   logToFile <- fromMaybe True . (>>= readMaybe) <$> SE.lookupEnv "LOG_TO_FILE"
--   logAsync <- fromMaybe False . (>>= readMaybe) <$> SE.lookupEnv "LOG_ASYNC"
--   logToConsole <- fromMaybe True . (>>= readMaybe) <$> SE.lookupEnv
--     "LOG_TO_CONSOLE"
--   logRawSql <- fromMaybe True . (>>= readMaybe) <$> SE.lookupEnv "LOG_RAW_SQL"
--   mettleLogApi <- fromMaybe False . (>>= readMaybe) <$> SE.lookupEnv "LOG_API"
--   logLevel <- fromMaybe T.Debug . (>>= readMaybe) <$> SE.lookupEnv "LOG_LEVEL"
--   _logFormatter <- fromMaybe True . (>>= readMaybe) <$> SE.lookupEnv
--     "CUSTOM_LOG_FORMATTER"
--   let shouldLogSql = if logRawSql
--         then T.UnsafeLogSQL_DO_NOT_USE_IN_PRODUCTION
--         else T.SafelyOmitSqlLogs
--   return T.defaultLoggerConfig { T._logToFile        = logToFile
--                                , T._logLevel         = logLevel
--                                , T._logFilePath      = logFile
--                                , T._isAsync          = logAsync
--                                , T._logRawSql        = shouldLogSql
--                                , T._logAPI           = mettleLogApi
--                                , T._logMaskingConfig = Nothing
--                                , T._logToConsole     = logToConsole -- uncomment this for perf in production
--                                }

configKmsDecrypt :: Config.Config -> IO Config.Config
configKmsDecrypt config@Config.Config {..} = do
  case Config.getNodeEnv of
    "integration"   -> do
      databaseWConfig <- sequence (kmsDecryptDBCreds <$> _databaseWConfig)
      databaseRConfig <- sequence (kmsDecryptDBCreds <$> _databaseRConfig)
      return $ Config.Config
        { _databaseWConfig = databaseWConfig
        , _databaseRConfig = databaseRConfig
        , ..
        }
    "sandbox"   -> do
      databaseWConfig <- sequence (kmsDecryptDBCreds <$> _databaseWConfig)
      databaseRConfig <- sequence (kmsDecryptDBCreds <$> _databaseRConfig)
      return $ Config.Config
        { _databaseWConfig = databaseWConfig
        , _databaseRConfig = databaseRConfig
        , ..
        }
    "production"   -> do
      databaseWConfig <- sequence (kmsDecryptDBCreds <$> _databaseWConfig)
      databaseRConfig <- sequence (kmsDecryptDBCreds <$> _databaseRConfig)
      return $ Config.Config
        { _databaseWConfig = databaseWConfig
        , _databaseRConfig = databaseRConfig
        , ..
        }
    _               -> pure config


kmsDecryptDBCreds :: Config.Database -> IO Config.Database
kmsDecryptDBCreds Config.Database {..} = do
  password <- do
    print ("using KMS_REGION : " <> Config.getKMSRegion)
    case Config.getKMSRegion of
      "ap-south-1"     -> decryptKMS Mumbai $ T.pack _password
      "ap-southeast-1" -> decryptKMS Singapore $ T.pack _password
      _                -> decryptKMS Mumbai $ T.pack _password
  return $ Config.Database
    { _password = T.unpack password
    , ..
    }
