{-# LANGUAGE DeriveAnyClass #-}
module Domain.Action.UI.CheckDuplicate
  ( checkDuplicate,
    CheckDuplicateReq (..),
    -- CheckDuplicateRes (..),
  )
where

import Domain.Types.Candidate
import qualified Data.Aeson as A
import qualified Domain.Types.Candidate 
import qualified Storage.Queries.CheckDuplicate as QRD
import qualified Storage.Queries.FlowMonad            as L
import EulerHS.Prelude

data CheckDuplicateReq = CheckDuplicateReq
  { dob :: Text,
    collegeName :: Maybe Text
  }
  deriving (Generic, Eq, Show, FromJSON)

-- data CheckDuplicateRes = CheckDuplicateRes{

-- }
checkDuplicate :: 
  -- (L.Flow m) =>
  L.MonadFlow m =>
  CheckDuplicateReq ->
  -- Text
  -- (Either String Candidate)
   m [Candidate]
checkDuplicate CheckDuplicateReq {..} =  QRD.findDuplicateCandidate 1 dob collegeName
  -- res
  -- res
  -- case res of
  --   Left err -> pure $ Left err
  --   Right candidate -> pure $ Right candidate