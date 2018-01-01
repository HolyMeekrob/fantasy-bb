module Header.Types exposing (..)

import Common exposing (User)
import Http


type alias Model =
    Maybe User


type Msg
    = RequestLogOut
    | LogOut (Result Http.Error String)
