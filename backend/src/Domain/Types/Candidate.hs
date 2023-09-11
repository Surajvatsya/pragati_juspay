{-# LANGUAGE DeriveAnyClass #-}
module Domain.Types.Candidate where
import EulerHS.Prelude
import qualified Data.Time as Time
import qualified Data.Aeson as A
data Candidate  = Candidate
  { id :: Text,
    name :: Text,
    dob :: Text,
    phoneNumber :: Text,
    email :: Text,
    collegeName :: Maybe Text,
    resume :: Maybe Text,
    role :: Maybe Text,
    roleCategory :: Maybe Text,
    currentctc ::  Maybe Text,
    expectedctc :: Maybe Text,
    experience :: Maybe Text,
    createdAt :: Time.UTCTime,
    updatedAt :: Time.UTCTime
  }
  deriving (Generic,Show, ToJSON)