module Home.Types exposing (..)

import Common exposing (User)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    }


type Msg
    = HeaderMsg Header.Types.Msg
    | SetUser (Result Http.Error User)
