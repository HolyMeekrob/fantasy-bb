module Seasons.Create.Types exposing (..)

import Common.Types exposing (User)
import Header.Types
import Date exposing (Date)
import Http


type alias Model =
    { header : Header.Types.Model
    , pageState : PageState
    , title : String
    , start : Maybe Date
    , errors : List Error
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


type alias Error =
    ( FormField, String )


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchUser
    | SetUser (Result Http.Error User)
    | SetTitle String
    | SetStart String
    | SubmitForm
    | SeasonCreated (Result Http.Error Season)
