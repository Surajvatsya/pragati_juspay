module Storage.Queries.CheckDuplicate where


import Domain.Types.Candidate 

import qualified Database.Beam as B
-- import Database.Beam.Backend (autoSqlValueSyntax)
-- import qualified Database.Beam.Backend as BeamBackend
-- import qualified EulerHS.Language as L
-- import Kernel.Beam.Functions
-- import Kernel.External.Encryption
import Kernel.Prelude
-- import Kernel.Types.Common
-- import Kernel.Types.Id
-- import Kernel.Utils.Common
-- import qualified Sequelize as Se
import qualified Storage.Beam.Common as BeamCommon

findDuplicateCandidate ::
  (L.MonadFlow m, Log m) =>
  Int ->
  Text ->
  Text ->
  m (Maybe Candidate)
findDuplicateCandidate  limitVal  dob collegeName = do
  dbConf <- getMasterBeamConfig
  res <- L.runDB dbConf $
    L.findRows $
      B.select $
        B.limit_ (fromIntegral limitVal) $
            B.filter_'
              ( \candidate ->
                  candidate.dob B.==?. B.val_ dob
                    B.&&?. candidate.collegeName B.==?. B.val_ collegeName
              )
              B.all_ (BeamCommon.candidate BeamCommon.atlasDB)
  res' <- case res of
    Right x -> Just x
    Left _ -> Nothing