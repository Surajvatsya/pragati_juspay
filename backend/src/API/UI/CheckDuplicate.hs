module API.UI.CheckDuplicate where

import qualified Domain.Action.UI.CheckDuplicate as Domain
-- import Environment
-- import EulerHS.Prelude hiding (id)
-- import Kernel.Types.Id
-- import Kernel.Utils.Common
import Servant
import Domain.Types.Types
-- import Tools.Auth

type API =
  "pragati"
    :> ( "checkDuplicate"
          --  :> TokenAuth
           :> ReqBody '[JSON] Domain.CheckDuplicateReq
           :> Post '[JSON] Domain.CheckDuplicateRes
       )
usersApi :: Proxy API
usersApi = Proxy :: Proxy API
-- handler :: FlowServer API
-- handler =
--   checkDuplicate

-- checkDuplicate ::  Domain.CheckDuplicateReq -> FlowHandler Domain.CheckDuplicateRes
-- checkDuplicate = withFlowHandlerAPI . Domain.checkDuplicate 
