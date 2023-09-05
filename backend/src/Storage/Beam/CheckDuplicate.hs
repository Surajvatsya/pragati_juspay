module Storage.Beam.CheckDuplicate where


import Data.Serialize
import Data.Serialize
import qualified Data.Time as Time
import qualified Database.Beam as B
import Database.Beam.MySQL ()
import GHC.Generics (Generic)
import Kernel.Prelude hiding (Generic)
import Lib.Utils ()
import Lib.UtilsTH
import Sequelize

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
    currentCTC ::  B.C f (Maybe Text),
    expectedCTC :: B.C f (Maybe Text),
    experience :: B.C f (Maybe Text),
    createdAt :: B.C f Time.UTCTime,
    updatedAt :: B.C f Time.UTCTime
  }
  deriving (Generic, B.Beamable)

instance B.Table CandidateT where
  data PrimaryKey CandidateT f
    = Id (B.C f Text)
    deriving (Generic, B.Beamable)
  primaryKey = Id . id


candidateTMod :: CandidateT (B.FieldModification (B.TableField CandidateT))
candidateTMod =
  B.tableModification
    { id = B.fieldNamed "id",
      name = B.fieldNamed "name",
      dob = B.fieldNamed "dob",
      phoneNumber = B.fieldNamed "phoneNumber",
      email = B.fieldNamed "email",
      collegeName = B.fieldNamed "college",
      resume = B.fieldNamed "resume",
      roleCategory = B.fieldNamed "roleCategory",
      currentCTC = B.fieldNamed "currentCTC",
      expectedCTC = B.fieldNamed "expectedCTC",
      experience = B.fieldNamed "experience",
      createdAt = B.fieldNamed "created_at",
      updatedAt = B.fieldNamed "updated_at"
    }