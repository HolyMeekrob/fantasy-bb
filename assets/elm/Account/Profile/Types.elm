module Account.Profile.Types exposing (..)

import Common.Types exposing (User)
import Editable exposing (Editable)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , user : Editable User
    , pageState : PageState
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
