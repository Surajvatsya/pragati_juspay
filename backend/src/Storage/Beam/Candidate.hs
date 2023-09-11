{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE ImpredicativeTypes #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# OPTIONS_GHC -Wno-missing-signatures #-}
{-# LANGUAGE AllowAmbiguousTypes #-}

module Storage.Beam.Candidate where

import Data.Aeson 
import Control.Lens
import Data.Serialize
import qualified Data.Time as Time
import qualified Database.Beam as B
import qualified Database.Beam.Schema.Tables as B
import qualified Data.HashMap.Internal as HM
import qualified Data.Map.Strict as M
import Database.Beam.MySQL ()
-- import Kernel.Prelude hiding (Generic)
-- import Lib.Utils ()
-- import Lib.UtilsTH
import qualified Database.Beam.Schema.Tables as BST
import Sequelize
import EulerHS.Prelude hiding(id,Generic)
import qualified Storage.Beam.Utils as SBU 
import GHC.Generics (Generic)

data CandidateT f = CandidateT
  { id :: B.C f Text,
    name :: B.C f Text,
    dob :: B.C f Text,
    phoneNumber :: B.C f Text,
    email :: B.C f Text,
    collegeName :: B.C f (Maybe Text),
    resume :: B.C f (Maybe Text),
    role :: B.C f (Maybe Text),
    roleCategory :: B.C f (Maybe Text),
    currentctc ::  B.C f (Maybe Text),
    expectedctc :: B.C f (Maybe Text),
    experience :: B.C f (Maybe Text),
    createdAt :: B.C f Time.UTCTime,
    updatedAt :: B.C f Time.UTCTime
  }
  deriving (Generic, B.Beamable)

instance B.Table CandidateT where
  data PrimaryKey CandidateT f = CandidatePrimaryKey (B.C f Text) deriving (Generic, B.Beamable)
  primaryKey = CandidatePrimaryKey . Storage.Beam.Candidate.id 

type CandidatePrimaryKey = B.PrimaryKey CandidateT Identity

type Candidate = CandidateT Identity

instance FromJSON Candidate where
  parseJSON = genericParseJSON defaultOptions

instance ToJSON Candidate where
  toJSON =
    genericToJSON (defaultOptions)

deriving instance Show Candidate

deriving instance Eq Candidate

-- Candidate
--   (B.LensFor id )
--   (B.LensFor name )
--   (B.LensFor dob )
--   (B.LensFor phone_number )
--   (B.LensFor email )
--   (B.LensFor college_name)
--   (B.LensFor resume)
--   (B.LensFor role)
--   (B.LensFor role_category)
--   (B.LensFor current_ctc)
--   (B.LensFor expected_ctc)
--   (B.LensFor experience)
--   (B.LensFor created_at)
--   (B.LensFor updated_at)=B.tableLenses




-- instance B.Table CandidateT where
--   data PrimaryKey CandidateT f
--     = Id (B.C f Text)
--     deriving (Generic, B.Beamable)
--   primaryKey = Id . Storage.Beam.CheckDuplicate.id


instance ModelMeta CandidateT where
  modelFieldModification = candidateTMod
  modelTableName = "candidate"
  modelSchemaName = Just "pragati"
  
-- instance FromJSON Candidate where
--   parseJSON = genericParseJSON defaultOptions

-- instance ToJSON Candidate where
--   toJSON = genericToJSON defaultOptions

-- deriving stock instance Show Candidate
candidateTable :: B.EntityModification (B.DatabaseEntity be db) be (B.TableEntity CandidateT)
candidateTable =
  BST.setEntitySchema (Just "pragati")
    <> B.setEntityName "candidate"
    <> B.modifyTableFields candidateTMod

candidateTMod ::  CandidateT (B.FieldModification (B.TableField CandidateT))
candidateTMod = 
  B.tableModification
  {id = B.fieldNamed "id",
   name = B.fieldNamed "name",
   dob = B.fieldNamed "dob",
   phoneNumber = B.fieldNamed "phone_number",
   email = B.fieldNamed "email",
   collegeName = B.fieldNamed "college",
   resume = B.fieldNamed "resume",
   roleCategory = B.fieldNamed "role_category",
   currentctc = B.fieldNamed "current_ctc",
   expectedctc = B.fieldNamed "expected_ctc",
   experience = B.fieldNamed "experience",
   createdAt = B.fieldNamed "created_at",
   updatedAt = B.fieldNamed "updated_at"
  }

psToHs :: HM.HashMap Text Text
psToHs = HM.empty

candidateToHSModifiers :: M.Map Text (Value -> Value)
candidateToHSModifiers =
  M.empty

candidateToPSModifiers :: M.Map Text (Value -> Value)
candidateToPSModifiers =
  M.empty

instance Serialize Candidate where
  put = error "undefined"
  get = error "undefined"

-- insertExpression c = insertExpressions [c]

-- insertExpressions cs = B.insertExpressions (toRowExpression <$> cs)
--  where
--   toRowExpression Candidate {..} =
--     Candidate
--       (B.val_ _id )
--       (B.val_ _name )
--       (B.val_ _dob )
--       (B.val_ _phone_number )
--       (B.val_ _email )
--       (B.val_ _college_name)
--       (B.val_ _resume)
--       (B.val_ _role)
--       (B.val_ _role_category)
--       (B.val_ _current_ctc)
--       (B.val_ _expected_ctc)
--       (B.val_ _experience)
--       (B.val_ _created_at)
--       (B.val_ _updated_at)
