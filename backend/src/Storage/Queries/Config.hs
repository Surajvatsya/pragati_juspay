{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
module Storage.Queries.Config
( Config(..)
-- , Redis
, Database(..)
-- , DBPoolDetails
, config'
-- , getServiceName
-- , getNodeEnv
-- , getApplicationHostName
-- , getDBSchema
-- , getKMSRegion
-- , isIntegration
-- , getMailerKey
-- , getCronMailList
-- , getIsOverdueFeatureActive
-- , getAWSRegion
) where

import qualified Data.Aeson as A
import qualified Data.Map           as M
-- import           Data.Text          as T
import           EulerHS.Prelude
import  EulerHS.Types()
-- import qualified Mettle.Environment as ENV
import      qualified     Storage.Beam.Utils as SBU
import  System.Environment()

newtype Config = Config
  {
    _databaseConfig       :: Database -- Writes Database
  }
  deriving stock (Generic, Eq, Show)

instance ToJSON Config where
  toJSON = genericToJSON SBU.stripAllLensPrefixOptions

-- data Redis = Redis
--   { _password         :: Maybe Text
--   , _host             :: Text
--   , _port             :: Word16
--   , _db               :: Integer
--   , _socket_keepalive :: Bool
--   }
--   deriving (Generic, Eq, Show)

-- instance FromJSON Redis where
--   parseJSON = genericParseJSON SBU.stripAllLensPrefixOptions

-- instance ToJSON Redis where
--   toJSON = genericToJSON SBU.stripAllLensPrefixOptions

data Database = Database
  { _host     :: String
  , _port     :: Word16
  , _user     :: String
  , _password :: String
  , _db       :: String
  }
  deriving stock (Generic, Eq, Show)

instance FromJSON Database where
  parseJSON = genericParseJSON SBU.stripAllLensPrefixOptions

instance ToJSON Database where
  toJSON = genericToJSON SBU.stripAllLensPrefixOptions

-- data DBPoolDetails = DBPoolDetails
--   { _pool           :: Int
--   , _maxIdleTime    :: Int
--   , _maxConnections :: Int
--   }
--   deriving (Generic, Eq, Show)

-- instance FromJSON DBPoolDetails where
--   parseJSON = genericParseJSON SBU.stripAllLensPrefixOptions

-- instance ToJSON DBPoolDetails where
  -- toJSON = genericToJSON SBU.stripAllLensPrefixOptions

data DType
  = W
  | R
  deriving stock (Eq)


config' :: IO Config
config' = do
  return $
    Config
      {
        _databaseConfig = 
          Database
              { _host =  "localhost" 
              , _port =  5432 
              , _user =  "postgres" 
              , _password =  "root"
              , _db =  "atlasDB"
              -- , _sslMode = Nothing
              }
        
          -- getDatabases envMap "CONFIG" W $ (fromMaybe 1 . (>>= readMaybe)) $ M.lookup "CONFIG_DB_COUNT" envMap
      -- ,  _databaseRConfig =
          -- getDatabases envMap "CONFIG" R ((fromMaybe 1 . (>>= readMaybe)) $ M.lookup "CONFIG_DB_COUNT" envMap)
  
     
      }
  -- _envMap <- M.fromList <$> SE.getEnvironment
  -- makeConfigFromEnv _envMap

-- makeConfigFromEnv :: M.Map String String -> IO Config
-- makeConfigFromEnv envMap = do
--   let name = fromMaybe "development" $ M.lookup "NODE_ENV" envMap
  -- return $
  --   Config
  --     { _redis =
  --         Redis
  --           { _host = T.pack . fromMaybe "localhost" $ M.lookup "REDIS_HOST" envMap
  --           , _port = (fromMaybe 6379 . (>>= readMaybe)) $ M.lookup "REDIS_PORT" envMap
  --           , _password = redisPassword envMap
  --           , _db = 0
  --           , _socket_keepalive = True
  --           }
  --     , _configDBShardCount = (fromMaybe 1 . (>>= readMaybe)) $ M.lookup "CONFIG_DB_SHARD_COUNT" envMap
  --     , _configDBCount = (fromMaybe 1 . (>>= readMaybe)) $ M.lookup "CONFIG_DB_COUNT" envMap
  --     , _databaseWConfig =
  --         getDatabases envMap "CONFIG" W $ (fromMaybe 1 . (>>= readMaybe)) $ M.lookup "CONFIG_DB_COUNT" envMap
  --     ,  _databaseRConfig =
  --         getDatabases envMap "CONFIG" R ((fromMaybe 1 . (>>= readMaybe)) $ M.lookup "CONFIG_DB_COUNT" envMap)
  --     , _dbPoolDetails =
  --         DBPoolDetails
  --           { _pool = (fromMaybe 1 . (>>= readMaybe)) $ M.lookup "DB_POOL" envMap
  --           , _maxIdleTime = (fromMaybe 10 . (>>= readMaybe)) $ M.lookup "DB_MAX_IDLE_TIMEOUT" envMap
  --           , _maxConnections = (fromMaybe 50 . (>>= readMaybe)) $ M.lookup "DB_MAX_CONNECTIONS" envMap
  --           }
  --     , _useDbSharding = (fromMaybe False . (>>= readMaybe)) $ M.lookup "USE_DB_SHARDING" envMap
  --     , _dBShardCount = (fromMaybe 1 . (>>= readMaybe)) $ M.lookup "TX_DB_SHARD_COUNT" envMap
  --     , _dBCount = (fromMaybe 1 . (>>= readMaybe)) $ M.lookup "TX_DB_COUNT" envMap
  --     , _useReadSlave = (fromMaybe False . (>>= readMaybe)) $ M.lookup "USE_READ_SLAVE" envMap
  --     , _isMaskingEnabled = (fromMaybe (getDefaultMask name) . (>>= readMaybe)) $ M.lookup "MASKING_ENABLED" envMap
  --     , _applicationHostName = T.pack . fromMaybe "METTLE_HOST" $ M.lookup "HOSTNAME" envMap
  --     , _isClusterRedisEnabled = fromMaybe False . (>>= readMaybe) $ M.lookup "USE_CLUSTER_REDIS" envMap
  --     , _enablePrometheus = fromMaybe False . (>>= readMaybe) $ M.lookup "PROMETHEUS_ENABLED" envMap
  --     }

-- getDatabases :: M.Map String String -> String -> DType -> Int -> [Database]
-- getDatabases envMap prefix t no =
--   if (fromMaybe False . (>>= readMaybe)) $ M.lookup "USE_DB_SHARDING" envMap
--     then EulerHS.Prelude.foldr go [] [0 .. no - 1]
--     else [getDatabase envMap prefix t]
--   where
--     go i acc =
--       let v =
--             if t == R
--               then "_READ_"
--               else "_"
--           _host = fromMaybe "localhost1" $ M.lookup (prefix <> "_DB" <> v <> "HOST_" <> show i) envMap
--           _port = (fromMaybe 5432 . (>>= readMaybe)) $ M.lookup (prefix <> "_DB" <> v <> "PORT_" <> show i) envMap
--           _user = fromMaybe "mettle" $ M.lookup (prefix <> "_DB" <> v <> "USER_" <> show i) envMap
--           _password = fromMaybe "mettle" $ M.lookup (prefix <> "_DB" <> v <> "PASSWORD_" <> show i) envMap
--           _db = fromMaybe "mettledb" $ M.lookup (prefix <> "_DB" <> v <> "NAME_" <> show i) envMap
--           _sslMode = (>>= readMaybe) $ M.lookup (prefix <> "_DB" <> v <> "SSL_MODE") envMap
--        in Database {..} : acc

-- getDatabase :: M.Map String String -> String -> DType -> Database
-- getDatabase envMap _ t =
--   if t == R
--     then
--       Database
--         { _host = fromMaybe "localhost" $ dbRHost "" envMap
--         , _port = (fromMaybe 5432 . (>>= readMaybe)) $ dbRPort "" envMap
--         , _user = fromMaybe "mettle" $ dbRUser "" envMap
--         , _password = fromMaybe "mettle" $ dbRPass "" envMap
--         , _db = fromMaybe "mettledb" $ dbRName "" envMap
--         , _sslMode = (>>= readMaybe) $ dbRSSLMode "" envMap
--         }
--     else
--       Database
--         { _host = fromMaybe "localhost" $ M.lookup "_DB_HOST" envMap
--         , _port = (fromMaybe 5432 . (>>= readMaybe)) $ M.lookup "_DB_PORT" envMap
--         , _user = fromMaybe "mettle" $ M.lookup "_DB_USER" envMap
--         , _password = fromMaybe "mettle" $ M.lookup "_DB_PASSWORD" envMap
--         , _db = fromMaybe "mettledb" $ M.lookup "_DB_NAME" envMap
--         , _sslMode = (>>= readMaybe) $ M.lookup "_DB_SSL_MODE" envMap
--         }

--- helpers ----
-- getDefaultMask :: String -> Bool
-- getDefaultMask env =
--   case env of
--     "uat"        -> True
--     "axis_uat"   -> True
--     "production" -> True
--     _            -> False

-- dbRHost :: String -> M.Map String String -> Maybe String
-- dbRHost s envMap = M.lookup (s <> "DB_READ_HOST1") envMap <|> M.lookup (s <> "_DB_HOST") envMap

-- dbRPort :: String -> M.Map String String -> Maybe String
-- dbRPort s envMap = M.lookup (s <> "DB_READ_PORT1") envMap <|> M.lookup (s <> "_DB_PORT") envMap

-- dbRUser :: String -> M.Map String String -> Maybe String
-- dbRUser s envMap = M.lookup (s <> "DB_READ_USER") envMap <|> M.lookup (s <> "_DB_USER") envMap

-- dbRPass :: String -> M.Map String String -> Maybe String
-- dbRPass s envMap = M.lookup (s <> "DB_READ_PASSWORD") envMap <|> M.lookup (s <> "_DB_PASSWORD") envMap

-- dbRName :: String -> M.Map String String -> Maybe String
-- dbRName s envMap = M.lookup (s <> "DB_READ_NAME") envMap <|> M.lookup (s <> "_DB_NAME") envMap

-- dbRSSLMode :: String -> M.Map String String -> Maybe String
-- dbRSSLMode s envMap = M.lookup (s <> "DB_READ_SSL_MODE") envMap <|> M.lookup (s <> "_DB_SSL_MODE") envMap

-- redisPassword :: M.Map String String -> Maybe Text
-- redisPassword envMap =
--   case fromMaybe "false" $ M.lookup "REDIS_PASSWORD_REQ" envMap of
--     "false" -> Nothing
--     _ -> Just $ T.pack . fromMaybe "NWx4nx6BFhpnBF6hRBrb" $ M.lookup "REDIS_AUTH" envMap

-- getApplicationHostName :: Text
-- getApplicationHostName = ENV.lookupText "HOSTNAME" ""

-- getServiceName :: Text
-- getServiceName = ENV.lookupText "SERVICE" "NA"

-- getNodeEnv :: Text
-- getNodeEnv = ENV.lookupText "NODE_ENV" "dev_integration"

-- getDBSchema :: Text
-- getDBSchema =  ENV.lookupText "_DB_SCHEMA" "public"

-- getKMSRegion :: Text
-- getKMSRegion = ENV.lookupText "KMS_REGION" "ap-south-1"

-- getAWSRegion :: Text
-- getAWSRegion = ENV.lookupText "AWS_REGION" "ap-south-1"

-- isIntegration :: Bool
-- isIntegration = getNodeEnv=="integration" || getNodeEnv=="dev_integration"

-- getMailerKey :: Text
-- getMailerKey = ENV.lookupText "MAILER_KEY" ""

-- getCronMailList :: Text
-- getCronMailList = ENV.lookupText "CRON_EMAIL_LIST" ""

-- getIsOverdueFeatureActive :: Bool
-- getIsOverdueFeatureActive = ENV.lookupBool "OVERDUE_FEATURE" "false"
