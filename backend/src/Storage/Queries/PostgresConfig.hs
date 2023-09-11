{-# LANGUAGE DeriveAnyClass #-}
module Storage.Queries.PostgresConfig where
import qualified Data.Text                     as Text
import qualified Database.Beam.Postgres        as BP
import qualified Database.Beam.Query           as B
import          EulerHS.Prelude as EP
import qualified EulerHS.Runtime               as R
import           EulerHS.Types
import qualified EulerHS.Types                 as T
import           Storage.Queries.Config        as CC
-- import           Mettle.Types.DB.DB            as DB
-- import qualified Mettle.Types.DB.Employee      as Employee
-- import           Mettle.Types.Engineering
-- import qualified Mettle.Utils.DB.Accessor      as Acc
-- import           Mettle.Utils.DB.ErrorHandling
import qualified Storage.Queries.FlowMonad      as L
import qualified Storage.Beam.Db as DB
import qualified Storage.Beam.Candidate as Candidate
data DBShardType
  = TX
  deriving (Show, Eq)
data AppException
  = SqlDBConnectionFailedException Text
  | KVDBConnectionFailedException Text
  deriving (Eq, Ord, Show, Generic, ToJSON, FromJSON, Exception)

throwOnFailedWithLog ::
     L.MonadFlow m
  => Show e
  => Bool
  -> R.LoggerRuntime
  -> Either e a
  -> (Text -> AppException)
  -> Text
  -> m ()
throwOnFailedWithLog _ _ (Left err) mkException msg = L.throwException $ mkException $ msg <> " " <> show err <> ""
  --Logger.logGenericErrM doMask loggerRuntime ("" :: Text) $ msg <> " " <> show err <> ""
throwOnFailedWithLog _ _ _ _ _ = pure ()


throwFailedWithLog :: L.MonadFlow m => Bool -> R.LoggerRuntime -> (Text -> AppException) -> Text -> m a
throwFailedWithLog _ _ mkException msg =
  --Logger.logDBErrM doMask loggerRuntime ("Unable to test" :: Text) $ msg <> ""
  L.throwException $ mkException $ msg <> ""

getPGConfig :: DBShardType -> String -> Int -> CC.Config -> L.Flow (T.DBConfig BP.Pg)
getPGConfig dbShardType op ind config = do
  let dbType' =  TX
      op' =  op
  L.runIO $ getPGConfig' dbType' op' ind config
-- getPGConfig dbShardType op ind config = do
--   let dbType' = if config ^. Acc.useDbSharding then dbShardType else TX
--       op' = if config ^. Acc.useReadSlave then op else "write"
--   L.runIO $ getPGConfig' dbType' op' ind config

getPGConfig' :: DBShardType -> String -> Int -> CC.Config -> IO (T.DBConfig BP.Pg)
getPGConfig' TX "read" ind config  = postgresReadTxDBConfig ind config
getPGConfig' TX "write" ind config = postgresTxDBConfig ind config
getPGConfig' _ _ _ _               = fail "no db config found"

postgresTxConfig :: Int -> CC.Config -> IO PostgresConfig
postgresTxConfig ind config = do
  return $
     PostgresConfig
      { connectHost =  "localhost"
      , connectPort = 5432
      , connectUser = "postgres"
      , connectPassword = "root"
      , connectDatabase = "atlasDB"
      -- , sslMode = ((config ^. Acc.databaseRConfig) !! ind) ^. Acc.sslMode
      }

postgresTxDBConfig :: Int -> CC.Config -> IO (T.DBConfig BP.Pg)
postgresTxDBConfig ind config = do
  postgresConfig' <- postgresTxConfig ind config
  poolConfig' <- poolConfig config
  return $
    T.mkPostgresPoolConfig (Text.pack $ "newtonPostgresTxDB" <> show ind) postgresConfig' poolConfig'


postgresReadTxConfig :: Int -> CC.Config -> IO PostgresConfig
postgresReadTxConfig ind config = do
  return $
    PostgresConfig
      { connectHost =  "localhost"
      , connectPort = 5432
      , connectUser = "postgres"
      , connectPassword = "root"
      , connectDatabase = "atlasDB"
      -- , sslMode = ((config ^. Acc.databaseRConfig) !! ind) ^. Acc.sslMode
      }

postgresReadTxDBConfig :: Int -> CC.Config -> IO (T.DBConfig BP.Pg)
postgresReadTxDBConfig ind config = do
  postgresConfig' <- postgresReadTxConfig ind config
  poolConfig' <- poolConfig config
  return $
    T.mkPostgresPoolConfig
      (Text.pack $ "newtonPostgresReadTxDB" <> show ind)
      postgresConfig'
      poolConfig'



poolConfig :: CC.Config -> IO T.PoolConfig
poolConfig config = do
  return $
    T.PoolConfig
      { stripes = 1
      , keepAlive = 10
      , resourcesPerStripe = 50
      }

initAndTest :: L.MonadFlow m => Bool -> R.LoggerRuntime -> Text -> (T.DBConfig BP.Pg -> m (DBResult (Maybe a))) -> T.DBConfig BP.Pg -> m ()
initAndTest doMask loggerRuntime str testDBConnection postgresDBConfig' = do
  ePool <- L.initSqlDBConnection postgresDBConfig'
  throwOnFailedWithLog
    doMask
    loggerRuntime
    ePool
    SqlDBConnectionFailedException
    ("Failed to initialize connection to " <> str)
  conn <- L.getSqlDBConnection postgresDBConfig'
  throwOnFailedWithLog
    doMask
    loggerRuntime
    conn
    SqlDBConnectionFailedException
    ("Failed to get connection to " <> str)
  res <- testDBConnection postgresDBConfig'
  EP.whenLeft res $ \err -> do
    --L.logDBErrM doMask loggerRuntime "Error occurred while testing:" err
    throwFailedWithLog
      doMask
      loggerRuntime
      SqlDBConnectionFailedException
      ("Failed to test the connection to " <> show err)

testTxDBConnection ::
  L.MonadFlow m =>
  Int ->
  CC.Config ->
  R.LoggerRuntime ->
  T.DBConfig BP.Pg ->
  m (DBResult (Maybe Candidate.Candidate))
testTxDBConnection ind config loggerRuntime postgresDBConfig' = do
  conn <- getConn postgresDBConfig' False loggerRuntime
  L.runDB conn $
    L.findRow $ B.select $ B.limit_ 1 $ B.all_ (DB.candidate DB.atlasDB)

getConn :: L.MonadFlow m => T.DBConfig beM -> Bool -> R.LoggerRuntime -> m (T.SqlConn beM)
getConn cfg doMask loggerRuntime =
  L.getSqlDBConnection cfg >>= \case
    Left e -> throwFailedWithLog doMask loggerRuntime SqlDBConnectionFailedException (show e)
    Right c -> pure c

prepareDBConnections :: L.MonadFlow m => CC.Config -> R.LoggerRuntime -> m ()
prepareDBConnections config loggerRuntime = do
  -- let doMask = config ^. Acc.isMaskingEnabled
  -- Initializing MettleWrite DB
  -- mapM_ (\ind -> initAndTest False loggerRuntime "PragatiWrite" (testTxDBConnection ind config loggerRuntime) =<< L.runIO (postgresTxDBConfig ind config)) [0 .. (config ^. Acc.configDBCount) -1]
  mapM_ (\ind -> initAndTest False loggerRuntime "PragatiWrite" (testTxDBConnection ind config loggerRuntime) =<< L.runIO (postgresTxDBConfig ind config)) [0]
  -- Initializing MettleRead DB
  mapM_ (\ind -> initAndTest False loggerRuntime "PragatiRead" (testTxDBConnection ind config loggerRuntime) =<< L.runIO (postgresReadTxDBConfig ind config)) [0]

getOrInitConn :: T.DBConfig beM -> Bool -> R.LoggerRuntime -> L.Flow (T.SqlConn beM)
getOrInitConn cfg doMask loggerRuntime =
  L.getOrInitSqlConn cfg >>= \case
    Left e -> throwFailedWithLog doMask loggerRuntime SqlDBConnectionFailedException (show e)
    Right c -> pure c