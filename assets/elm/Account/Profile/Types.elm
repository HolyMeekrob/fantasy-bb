module Account.Profile.Types exposing (..)

import Common.Types exposing (User)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , user : User
    , pageState : PageState
    , input : Input
    }


type alias Input =
    { bio : String
    }


type PageState
    = Loading
    | View
    | Edit


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchUser
    | SetUser (Result Http.Error User)
    | EditProfile
    | CancelEdit
    | SaveEdit
    | ViewProfile (Result Http.Error Bool)
    | BioChanged String
