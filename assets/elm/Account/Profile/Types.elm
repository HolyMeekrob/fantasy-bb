module Account.Profile.Types exposing (..)

import Common.Types exposing (User)
import Editable exposing (Editable)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , user : Editable User
    , pageState : PageState
    , errors : List String
    }


type PageState
    = Loading
    | Loaded


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchUser
    | SetUser (Result Http.Error User)
    | EditProfile
    | CancelEdit
    | SaveProfile
    | ProfileSaved (Result Http.Error Bool)
    | UpdateBio String
