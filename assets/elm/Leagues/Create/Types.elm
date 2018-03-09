module Leagues.Create.Types exposing (..)

import Common.Types exposing (User)
import Common.Views.Forms exposing (Error)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , pageState : PageState
    , name : String
    , errors : List (Error FormField)
    }


type PageState
    = Loading
    | Loaded


type FormField
    = Name


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchUser
    | SetUser (Result Http.Error User)
