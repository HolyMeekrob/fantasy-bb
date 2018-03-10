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


type alias League =
    { id : Int }


type PageState
    = Loading
    | Loaded


type FormField
    = Name
    | Summary


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchUser
    | SetUser (Result Http.Error User)
    | SetName String
    | SubmitForm
    | LeagueCreated (Result Http.Error League)
