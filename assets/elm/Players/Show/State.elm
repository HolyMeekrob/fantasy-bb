module Players.Show.State exposing (init, subscriptions, update)

import Players.Show.Rest exposing (initialize, updatePlayer)
import Players.Show.Types as Types
    exposing
        ( Flags
        , FormField
        , Model
        , Msg
        , Player
        )
import Common.Commands exposing (send)
import Common.String exposing (toMaybe)
import Common.Views.Forms exposing (Error)
import Common.Navigation exposing (findId)
import Date
import Editable
import Task
import Header.State
import Header.Types
import Validate exposing (Validator, validate)


initialModel : String -> Model
initialModel idStr =
    let
        player =
            { id = findId idStr
            , firstName = ""
            , lastName = ""
            , nickname = Nothing
            , hometown = Nothing
            , birthday = Nothing
            }
    in
        { header = Header.State.initialModel
        , pageState = Types.Loading
        , player = Editable.ReadOnly player
        , errors = []
        , userCanEdit = False
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags.location, send Types.FetchInitialData )


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

        Types.FetchInitialData ->
            model ! [ initialize <| .id (Editable.value model.player) ]

        Types.SetInitialData (Err _) ->
            model ! []

        Types.SetInitialData (Ok ( user, player )) ->
            let
                header =
                    model.header

                headerModel =
                    { header | user = Just user }
            in
                { model
                    | header = headerModel
                    , pageState = Types.Loaded
                    , player = Editable.ReadOnly player
                    , userCanEdit = user.isAdmin
                }
                    ! []

        Types.EditPlayer ->
            { model | player = Editable.edit model.player } ! []

        Types.CancelEdit ->
            { model
                | errors = []
                , player = Editable.cancel model.player
            }
                ! []

        Types.SetFirstName name ->
            updatePlayerField
                (\player -> { player | firstName = name })
                model

        Types.SetLastName name ->
            updatePlayerField
                (\player -> { player | lastName = name })
                model

        Types.SetNickname name ->
            updatePlayerField
                (\player -> { player | nickname = toMaybe name })
                model

        Types.SetHometown hometown ->
            updatePlayerField
                (\player -> { player | hometown = toMaybe hometown })
                model

        Types.SetBirthday birthday ->
            let
                newBirthday =
                    Date.fromString birthday
                        |> Result.toMaybe
            in
                updatePlayerField
                    (\player -> { player | birthday = newBirthday })
                    model

        Types.SubmitForm ->
            let
                validationErrors =
                    validate validator model
            in
                if (List.isEmpty validationErrors) then
                    { model
                        | pageState = Types.Loading
                        , errors = []
                    }
                        ! [ updatePlayer (Editable.value model.player) ]
                else
                    { model | errors = validationErrors } ! []

        Types.PlayerUpdated (Err _) ->
            let
                newModel =
                    { model
                        | pageState = Types.Loaded
                        , errors =
                            [ ( Types.Summary, "Error updating player" ) ]
                    }
            in
                newModel ! []

        Types.PlayerUpdated (Ok _) ->
            { model | pageState = Types.Loaded, player = Editable.save model.player }
                ! [ addNotification "Player successfully saved" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


updatePlayerField : (Player -> Player) -> Model -> ( Model, Cmd Msg )
updatePlayerField func model =
    let
        updatedPlayer =
            Editable.map func model.player
    in
        { model | player = updatedPlayer } ! []


getPlayer : Model -> Player
getPlayer model =
    Editable.value model.player


getFirstName : Model -> String
getFirstName =
    getPlayer >> .firstName


getLastName : Model -> String
getLastName =
    getPlayer >> .lastName


validator : Validator (Error FormField) Model
validator =
    Validate.all
        [ Validate.ifBlank
            getFirstName
            ( Types.FirstName, "First name is required" )
        , Validate.ifBlank
            getLastName
            ( Types.LastName, "Last name is required" )
        ]


addNotification : String -> Cmd Msg
addNotification message =
    Task.perform
        (\msg -> Types.HeaderMsg (Header.Types.AddNotification msg))
        (Task.succeed message)
