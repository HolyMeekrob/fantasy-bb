module Account.Profile.State exposing (init, subscriptions, update)

import Account.Profile.Rest as Rest exposing (saveProfile)
import Account.Profile.Types as Types exposing (Model, Msg)
import Common.Commands exposing (send)
import Common.Rest exposing (fetch, userRequest)
import Editable
import Header.State
import Header.Types
import Task


initialModel : Model
initialModel =
    let
        user =
            { firstName = ""
            , lastName = ""
            , email = ""
            , bio = ""
            , avatarUrl = ""
            , isAdmin = False
            }
    in
        { user = Editable.ReadOnly user
        , header = Header.State.initialModel
        , pageState = Types.Loading
        , errors = []
        }


init : ( Model, Cmd Msg )
init =
    ( initialModel, send Types.FetchUser )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Types.HeaderMsg headerMsg ->
            let
                ( headerModel, headerCmd ) =
                    Header.State.update headerMsg model.header
            in
                { model | header = headerModel }
                    ! [ Cmd.map Types.HeaderMsg headerCmd ]

        Types.FetchUser ->
            { model | pageState = Types.Loading }
                ! [ fetch userRequest Types.SetUser ]

        Types.SetUser (Err _) ->
            initialModel ! []

        Types.SetUser (Ok newUser) ->
            let
                header =
                    model.header

                headerModel =
                    { header | user = Just newUser }
            in
                { model
                    | user = Editable.ReadOnly newUser
                    , header = headerModel
                    , pageState = Types.Loaded
                }
                    ! []

        Types.EditProfile ->
            { model | user = Editable.edit model.user } ! []

        Types.CancelEdit ->
            { model | user = Editable.cancel model.user, errors = [] } ! []

        Types.SaveProfile ->
            { model | pageState = Types.Loading }
                ! [ saveProfile (Editable.value model.user) ]

        Types.ProfileSaved (Err _) ->
            { model
                | pageState = Types.Loaded
                , errors = [ "Error saving profile" ]
            }
                ! []

        Types.ProfileSaved (Ok _) ->
            { model
                | pageState = Types.Loaded
                , user = Editable.save model.user
                , errors = []
            }
                ! [ addNotification "Profile saved" ]

        Types.UpdateBio newBio ->
            let
                updatedUser =
                    Editable.map
                        (\user -> { user | bio = newBio })
                        model.user
            in
                { model | user = updatedUser } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


addNotification : String -> Cmd Msg
addNotification message =
    Task.perform
        (\msg -> Types.HeaderMsg (Header.Types.AddNotification msg))
        (Task.succeed message)
