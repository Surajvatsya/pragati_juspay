-- {-# LANGUAGE NamedWildCards #-}
-- {-# LANGUAGE PartialTypeSignatures #-}
-- {-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

-- {-# HLINT ignore "Use newtype instead of data" #-}

module Storage.Beam.Common where

import qualified Database.Beam as B
import GHC.Generics (Generic)

atlasDB :: B.DatabaseSettings be AtlasDB
atlasDB =
  B.defaultDbSettings
    `B.withDbModification` B.dbModification
      { candidate = candidateTable
      }

newtype AtlasDB f = AtlasDB
  { candidate :: f (B.TableEntity CandidateT)
  }
  deriving (Generic, B.Database be)
