module Players.Show.Types exposing (..)

import Common.Types exposing (User)
import Common.Views.Forms exposing (Error)
import Date exposing (Date)
import Editable exposing (Editable)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , pageState : PageState
    , player : Editable Player
    , errors : List (Error FormField)
    , userCanEdit : Bool
    }


type alias Player =
    { id : Int
    , firstName : String
    , lastName : String
    , nickname : Maybe String
    , hometown : Maybe String
    , birthday : Maybe Date
    }


type alias Flags =
    { location : String }


type PageState
    = Loading
    | Loaded


type FormField
    = FirstName
    | LastName
    | Nickname
    | Hometown
    | Birthday
    | Summary


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchInitialData
    | SetInitialData (Result Http.Error ( User, Player ))
    | EditPlayer
    | CancelEdit
    | SetFirstName String
    | SetLastName String
    | SetNickname String
    | SetHometown String
    | SetBirthday String
    | SubmitForm
    | PlayerUpdated (Result Http.Error Player)
