{-# LANGUAGE DeriveAnyClass #-}
module API.UI.CheckDuplicate where
-- import 
import qualified Domain.Action.UI.CheckDuplicate as Domain
import qualified Storage.Queries.FlowMonad            as L
import Servant
import Domain.Types.Candidate
import qualified Data.Vault.Lazy                   as V
import qualified Domain.Action.UI.CheckDuplicate as DAU
import qualified Data.HashMap.Lazy                 as HM
import qualified EulerHS.Language          as L (logInfo)
import Data.Aeson 
import qualified Data.UUID                as UUID (toText)
import qualified Data.UUID.V4             as UUID (nextRandom)
import qualified EulerHS.Runtime          as T
import qualified EulerHS.Interpreters     as I
import qualified Data.Text                as T
import  Storage.Queries.FlowMonad
import           System.Environment 
import qualified          EulerHS.Types as T
import  EulerHS.Prelude 
import qualified Data.Text.Encoding        as T
-- data SessionIdKey
--   = SessionIdKey
--   deriving (FromJSON, Generic, Show)

-- instance T.OptionEntity SessionIdKey Text

-- instance ToJSON SessionIdKey where
--   toJSON = genericToJSON $ defaultOptions {tagSingleConstructors = True}

-- type DefaultRespHeaders =
--   Headers '[Header "x-requestid" Text, Header "x-sessionid" Text, Header "X-Frame-Options" Text, Header "X-Content-Type-Options" Text, Header "X-XSS-Protection" Text, Header "Strict-Transport-Security" Text]

-- type FlowHandler = ReaderT L.AppState (ExceptT ServerError IO)

-- data ReqHeadersKey
--   = ReqHeadersKey
--   deriving (FromJSON, Generic, Show)

-- instance T.OptionEntity ReqHeadersKey (HashMap Text Text)

-- instance ToJSON ReqHeadersKey where
--   toJSON = genericToJSON $ defaultOptions {tagSingleConstructors = True}

-- data RequestIdKey
--   = RequestIdKey
--   deriving (FromJSON, Generic, Show)

-- instance T.OptionEntity RequestIdKey Text

-- instance ToJSON RequestIdKey where
--   toJSON = genericToJSON $ defaultOptions {tagSingleConstructors = True}


-- data ChannelNameKey
--   = ChannelNameKey
--   deriving (FromJSON, Generic, Show)

-- instance T.OptionEntity ChannelNameKey ByteString

-- instance ToJSON ChannelNameKey where
--   toJSON = genericToJSON $ defaultOptions {tagSingleConstructors = True}


-- data RequestTokenKey
--   = RequestTokenKey
--   deriving (FromJSON, Generic, Show)

-- instance T.OptionEntity RequestTokenKey Text

-- instance ToJSON RequestTokenKey where
--   toJSON = genericToJSON $ defaultOptions {tagSingleConstructors = True}

-- data HashedRequestTokenKey
--   = HashedRequestTokenKey
--   deriving (FromJSON, Generic, Show)

-- instance T.OptionEntity HashedRequestTokenKey Text

-- instance ToJSON HashedRequestTokenKey where
--   toJSON = genericToJSON $ defaultOptions {tagSingleConstructors = True}

-- data EnvKey
--   = EnvKey
--   deriving (FromJSON, Generic, Show)

-- instance T.OptionEntity EnvKey Text

-- instance ToJSON EnvKey where
--   toJSON = genericToJSON $ defaultOptions {tagSingleConstructors = True}

-- defaultFlowWithTrace ::
--      --(ToJSON a, Show a)
--   V.Key (HM.HashMap Text Text)
--   -> Vault
--   -> Maybe (HM.HashMap Text Text)
--   -> L.Flow a
--   -> FlowHandler (DefaultRespHeaders a)
-- defaultFlowWithTrace key vault lg flow = do
--   uuid <- liftIO $ UUID.toText <$> UUID.nextRandom
--   let headers = fromMaybe HM.empty (V.lookup key vault)
--       optRid = HM.lookup "x-requestid" headers
--       token = HM.lookup "mettle-token" headers
--       rid = fromMaybe uuid optRid
--       optSessionId = HM.lookup "x-sessionid" headers
--       sessionId = fromMaybe rid optSessionId
--       logContext = HM.insert "sessionId" sessionId <$> lg
--   toFlowHandlerWithEnv rid logContext token (addTracing rid sessionId headers flow)
--   where
--     addTracing requestId sessionId headers flow' = do
--       L.setOption ReqHeadersKey headers
--       L.setOption RequestIdKey requestId
--       L.setOption SessionIdKey sessionId
--       flowResp <- try flow'
--       --void $ Utils.monitorAPI flowResp headers requestId sessionId Nothing 0.0 pspMode
--       case flowResp of
--         Right val -> return $ addHeader sessionId
--                             . addHeader requestId
--                             . addHeader "SAMEORIGIN"
--                             . addHeader "nosniff"
--                             . addHeader "1; mode=block"
--                             . addHeader "max-age=63072000; includeSubDomains"
--                             $ val
--         Left (err :: SomeException) -> L.throwExceptionWithoutCallStack err

-- type LogFunction m = MonadFlow m => Text -> Text -> m ()

-- logEventM
--   :: L.MonadFlow m
--   => ToJSON a
--   => LogFunction m
--   -> Bool
--   -> T.LoggerRuntime
--   -> T.LogLevel
--   -> Category
--   -> Text
--   -> a
--   -> m ()
-- logEventM _ _ _ _ _ _ _ = return ()

-- logInfo
--   :: ToJSON a
--   => Category
--   -> Text
--   -> a
--   -> L.Flow ()
-- logInfo cat label val = do
--   loggerRuntime <- L.getLoggerRuntime
--   _config <- L.getConfig
--   logEventM L.logInfo True loggerRuntime T.Info cat label val

-- logAPI
--   :: ToJSON a
--   => Text
--   -> a
--   -> L.Flow ()
-- logAPI = logInfo (API "Generic")

type API =
  "pragati"
    :> ( "checkDuplicate"
          --  :> TokenAuth
           :> ReqBody '[JSON] Domain.CheckDuplicateReq
           :> Post '[JSON]  [Candidate]
       )


-- data Category
--   = DB Text
--   | API Text
--   | System
--   | BusinessLogic
--   | Generic
--   deriving (Generic, FromJSON, Show, Read)

-- instance ToJSON Category where
--   toJSON (DB txt)      = String txt
--   toJSON (API txt)     = String txt
--   toJSON System        = String "System"
--   toJSON BusinessLogic = String "BusinessLogic"
--   toJSON Generic       = String "Generic"


pragatiAPIs :: Proxy API
pragatiAPIs = Proxy :: Proxy API

-- handler :: FlowServer API
-- handler =
--   checkDuplicate

-- checkDuplicate ::  Domain.CheckDuplicateReq -> FlowHandler Domain.CheckDuplicateRes
-- checkDuplicate = withFlowHandlerAPI . Domain.checkDuplicate 

-- sha256TextHash :: Text -> Text
-- sha256TextHash payload = show (Hash.hash @_ @Hash.SHA256 (T.encodeUtf8 payload))

-- checkDuplicateCandidateHandler :: V.Key (HM.HashMap Text Text) -> V.Vault ->  Domain.CheckDuplicateReq  -> FlowHandler (DefaultRespHeaders [Candidate])
-- checkDuplicateCandidateHandler key vault request = do
--   defaultFlowWithTrace
--     key
--     vault
--     (Just $ HM.singleton "/checkDuplicate" "checkDuplicate Invoked")
--     (logAPI "checkDuplicate Invoked." ("" :: String) *> (pure ()) *> DAU.checkDuplicate request)

-- toFlowHandlerWithEnv :: T.Text -> Maybe (HashMap Text Text) -> Maybe Text -> L.Flow a -> FlowHandler a
-- toFlowHandlerWithEnv requestId' loggerCtx token flow = do
--   appState@AppState{..} <- ask
--   counterRef <- liftIO $ newIORef 0
--   let updateState = do
--         L.setOption ChannelNameKey channelName
--         L.setOption RequestIdKey requestId'
--         L.setOption RequestTokenKey ""
--         -- L.setOption HashedRequestTokenKey $ sha256TextHash (fromMaybe "" token)
--         L.setOption HashedRequestTokenKey ""
--         env' <- L.runIO $ fromMaybe "development" <$> lookupEnv "NODE_ENV"
--         L.setOption EnvKey (T.pack env')
--       (T.LoggerRuntime a b c d d' _ e hdl _) = T._loggerRuntime $ T._coreRuntime runTime
--       flowRt' =
--         runTime {T._coreRuntime = T.CoreRuntime (T.LoggerRuntime a (fromMaybe b loggerCtx) c d d' counterRef e hdl Nothing)}
--   lift $ ExceptT $ try $ I.runFlow' (Just requestId') flowRt' $ runReaderT (updateState *> flow) (appState {runTime = flowRt'})
