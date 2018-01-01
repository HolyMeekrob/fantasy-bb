module Account.Profile.Types exposing (..)

import Common exposing (User)
import Http


type alias Model =
    { user : User
    }


type Msg
    = SetUser (Result Http.Error User)
