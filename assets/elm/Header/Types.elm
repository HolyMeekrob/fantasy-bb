module Header.Types exposing (..)

import Http


type alias Model =
    { user : User
    }


type alias User =
    { firstName : String
    , lastName : String
    , avatarUrl : String
    }


type Msg
    = SetUser (Result Http.Error User)
