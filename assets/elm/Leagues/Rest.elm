module Leagues.Rest exposing (initialize)

import Common.Rest exposing (fetch, userRequest)
import Leagues.Types as Types exposing (Msg)


initialize : Cmd Msg
initialize =
    fetch userRequest Types.SetInitialData
