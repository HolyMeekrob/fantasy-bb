module Seasons.Create.Types exposing (..)

import Common.Views.Forms exposing (Error)
import Common.Types exposing (User)
import Date exposing (Date)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , pageState : PageState
    , title : String
    , start : Maybe Date
    , errors : List (Error FormField)
    }


type PageState
    = Loading
    | Loaded


type alias Season =
    { id : Int
    , title : String
    , start : String
    }


type FormField
    = Title
    | Start
    | Summary


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchUser
    | SetUser (Result Http.Error User)
    | SetTitle String
    | SetStart String
    | SubmitForm
    | SeasonCreated (Result Http.Error Season)
