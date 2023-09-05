module Domain.Types.Candidate where

import qualified Data.Time as Time

data CandidateT f = CandidateT
  { id :: Text,
    name :: Text,
    dob :: Text,
    phoneNumber :: Text,
    email :: Text,
    collegeName :: Maybe Text,
    resume :: Maybe Text,
    role :: Maybe Text,
    roleCategory :: Maybe Text,
    currentCTC ::  Maybe Text,
    expectedCTC :: Maybe Text,
    experience :: Maybe Text,
    createdAt :: Time.UTCTime,
    updatedAt :: Time.UTCTime
  }
  deriving (Generic,Show)