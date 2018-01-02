module Account.Profile.Types exposing (..)

import Common.Types exposing (User)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , user : User
    }


type Msg
    = HeaderMsg Header.Types.Msg
    | SetUser (Result Http.Error User)
