module Domain.Action.UI.CheckDuplicate
  ( checkDuplicate,
    CheckDuplicateReq (..),
    CheckDuplicateRes (..),
  )
where

import Domain.Types.Candidate

import qualified Domain.Types.CheckDuplicate as D
import qualified Domain.Types.Merchant as DM
import qualified Domain.Types.Person as SP
import qualified Kernel.Beam.Functions as B
import Kernel.Prelude
import Kernel.Storage.Esqueleto (EsqDBReplicaFlow)
import qualified Kernel.Storage.Hedis as Redis
import Kernel.Types.APISuccess (APISuccess (Success))
import Kernel.Types.Id
import Kernel.Utils.Common
import qualified Kernel.Utils.Text as TU
import Storage.CachedQueries.CacheConfig (HasCacheConfig)
import qualified Storage.CachedQueries.Merchant.TransporterConfig as QTC
import qualified Storage.Queries.CheckDuplicate as QRD
import Tools.Error

data CheckDuplicateReq = CheckDuplicateReq
  { dob :: Text,
    collegeName :: Text
  }
  deriving (Generic, ToJSON, FromJSON, ToSchema, Show)


checkDuplicate ::
  ( HasCacheConfig r,
    Redis.HedisFlow m r,
    MonadFlow m,
    EsqDBReplicaFlow m r,
    EsqDBFlow m r
  ) =>
  CheckDuplicateReq ->
  m (Maybe Candidate)
checkDuplicate CheckDuplicateReq {..} = findDuplicateCandidate