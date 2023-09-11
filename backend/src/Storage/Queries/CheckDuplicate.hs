{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
module Storage.Queries.CheckDuplicate where
import qualified Data.Aeson as A
-- import qualified Domain.Types.Candidate as DDR
import qualified Database.Beam as B
import qualified EulerHS.Language as L hiding (Flow)
import qualified Storage.Beam.Db as DB
import qualified Database.Beam.Postgres as BP
import EulerHS.Types
-- import EulerHS.Types (DBConfig, OptionEntity)
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.SqlQQ
-- import Config
-- import Domain.Types.Candidate
import Database.PostgreSQL.Simple
import qualified Storage.Beam.Candidate         as DBCandidate
import qualified Storage.Queries.FlowMonad            as L
import qualified Storage.Queries.Dbquery           as Q
import Control.Exception.Safe 
import qualified Data.Time as T
import qualified Domain.Types.Candidate as Domain
import qualified Storage.Queries.PostgresConfig as PS
import qualified Storage.Queries.Config as CG
import EulerHS.Runtime
import EulerHS.Prelude
-- connectionInfo :: ConnectInfo
-- connectionInfo = defaultConnectInfo
--     { connectHost = "localhost"
--     , connectPort = 5432
--     , connectUser = "postgres"
--     , connectPassword = "root"
--     , connectDatabase = "mydbq"
--     }
-- data PsqlLocDbCfg = PsqlLocDbCfg
--   deriving stock (Generic, Typeable, Show, Eq)
--   deriving anyclass (A.ToJSON, A.FromJSON)

-- instance OptionEntity PsqlLocDbCfg (DBConfig BP.Pg)

-- getLocDbConfig :: (HasCallStack, L.MonadFlow m) => m (DBConfig BP.Pg)
-- getLocDbConfig = do
--   dbConf <- L.getOption PsqlLocDbCfg
--   case dbConf of
--     Just dbCnf' -> pure dbCnf'
--     Nothing -> L.throwException $  "LocationDb Config not found"

-- classes for converting from beam types to ttypes and vice versa
class
  FromTType' t a
    | t -> a
  where
  fromTType' :: (MonadThrow m, L.MonadFlow m) => t -> m (Maybe a)

class
  ToTType' t a
    | a -> t
  where
  toTType' :: a -> t

dbCandidateTable :: B.DatabaseEntity be DB.AtlasDB (B.TableEntity DBCandidate.CandidateT)
dbCandidateTable = DB.candidate DB.atlasDB 

-- findDuplicateCandidate ::
--   -- Int ->
--   Text ->
--   Maybe Text ->
--   (Maybe Candidate)
-- findDuplicateCandidate dob' collegeName' = do
--   res <- Q.findOne dbCandidateTable (\DBCandidate.CandidateT {..} -> (dob B.==?. B.val_ dob') B.&&?. (collegeName B.==?. B.val_ collegeName'))
--   case res of
--     Left err -> Nothing
--     Right candidateData -> case candidateData of
--         Nothing  -> Nothing
--         Just candidate -> do
--           maybeConvertedCandidate <- fromTType' candidate
--           maybeConvertedCandidate
        -- case maybeConvertedCandidate of
        --   Just convertedCandidate -> pure $ Right convertedCandidate
        --   Nothing -> return $ Left "Error while converting Candidate"

-- findDuplicateCandidate ::
--   -- Int ->
--   Text ->
--   Maybe Text ->
--   L.Flow (Either String  Candidate)
-- findDuplicateCandidate dob' collegeName' = do
--   res <- Q.findOne dbCandidateTable (\DBCandidate.CandidateT {..} -> (dob B.==?. B.val_ dob') B.&&?. (collegeName B.==?. B.val_ collegeName'))
--   case res of
--     Left err -> return $ Left "Error while fetching DuplicateCandidate"
--     Right candidateData -> case candidateData of
--       Nothing  -> pure $ Left "DuplicateCandidate not found"
--       Just candidate -> do
--         maybeConvertedCandidate <- fromTType' candidate
--         case maybeConvertedCandidate of
--           Just convertedCandidate -> pure $ Right convertedCandidate
--           Nothing -> return $ Left "Error while converting Candidate"


        -- pure $ Right candidate


-- findDuplicateCandidate ::
--   Text ->
--   Text ->
--   L.Flow (Either String Candidate)
-- findDuplicateCandidate dob collegeName = do
--   res <- Q.findOne dbCandidateTable $ \candidate ->
--     (candidate DB.^. DBCandidate.dob) B.==?. B.val_ dob B.&&?.
--     (candidate DB.^. DBCandidate.collegeName) B.==?. B.val_ collegeName

--   case res of
--     Left err -> return $ Left "Error while fetching DuplicateCandidate"
--     Right candidateData -> case candidateData of
--       Nothing -> pure $ Left "DuplicateCandidate not found"
--       Just candidate -> do
--         maybeConvertedCandidate <- fromTType' candidate
--         case maybeConvertedCandidate of
--           Just convertedCandidate -> pure $ Right convertedCandidate
--           Nothing -> return $ Left "Error while converting Candidate"


instance FromTType' DBCandidate.Candidate Domain.Candidate where
  fromTType' DBCandidate.CandidateT {..} = do
    pure $
      Just
        Domain.Candidate
            { id = "123",
              name = name,
              dob = dob, 
              phoneNumber = phoneNumber,
              email = email,
              collegeName = collegeName,
              resume = resume,
              role = role,
              roleCategory = roleCategory,
              currentctc = currentctc,
              expectedctc = expectedctc,
              experience = experience,
              createdAt =  createdAt,
              updatedAt =  updatedAt
            }

instance ToTType' DBCandidate.Candidate Domain.Candidate where
  toTType' Domain.Candidate {..} = do
    DBCandidate.CandidateT
      { DBCandidate.id = "123",
        DBCandidate.name = name,
        DBCandidate.dob = dob, 
        DBCandidate.phoneNumber = phoneNumber,
        DBCandidate.email = email,
        DBCandidate.collegeName = collegeName,
        DBCandidate.resume = resume,
        DBCandidate.role = role,
        DBCandidate.roleCategory = roleCategory,
        DBCandidate.currentctc = currentctc,
        DBCandidate.expectedctc = expectedctc,
        DBCandidate.experience = experience,
        DBCandidate.createdAt = createdAt,
        DBCandidate.updatedAt =  updatedAt
      }


findDuplicateCandidate ::
  L.MonadFlow m =>
  Int ->
  Text ->
  Maybe Text ->
  m  [Domain.Candidate]
findDuplicateCandidate  limitVal  dob' collegeName' = do
  -- dbConf <- getLocDbConfig
  config <- L.runIO $ CG.config'
  postgresDBConfig' <- L.runIO $ PS.postgresTxDBConfig 1 config
  loggerRuntime <- L.runIO $ createVoidLoggerRuntime
  conn <- PS.getConn postgresDBConfig' False loggerRuntime
  res <- L.runDB conn $
    L.findRows $
      B.select $
        B.limit_ (fromIntegral limitVal) $
            B.filter_'
              ( \DBCandidate.CandidateT {..} ->
                  (dob B.==?. B.val_ dob')
                    B.&&?. (collegeName B.==?. B.val_ collegeName')
              )
              $ B.all_ (DB.candidate DB.atlasDB)
  catMaybes <$> mapM fromTType' (fromRight [] res)
  -- case res of
  --   Right x -> do

  --   Left _ -> pure []
  -- res' <- case res of
  --   Right x -> do
  --     mbVal<- fromTType' x
  --     mbVal
  --   Left _ -> Nothing
  -- pure res'