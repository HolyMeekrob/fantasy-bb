module Players.Create.State exposing (init, subscriptions, update)

import Players.Create.Rest exposing (createPlayer)
import Players.Create.Types as Types exposing (FormField, Model, Msg, Player)
import Common.Commands exposing (send)
import Common.Navigation exposing (navigate)
import Common.Rest exposing (fetch, userRequest)
import Common.Views.Forms exposing (Error)
import Common.String exposing (toMaybe)
import Date exposing (Date)
import Header.State
import Validate exposing (Validator)


initialModel : Model
initialModel =
    { header = Header.State.initialModel
    , pageState = Types.Loading
    , player =
        { firstName = ""
        , lastName = ""
        , nickname = Nothing
        , hometown = Nothing
        , birthday = Nothing
        }
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
            model ! [ fetch userRequest Types.SetUser ]

        Types.SetUser (Err _) ->
            initialModel ! []

        Types.SetUser (Ok newUser) ->
            let
                header =
                    model.header

                headerModel =
                    { header | user = Just newUser }
            in
                { model | header = headerModel, pageState = Types.Loaded } ! []

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
                    Validate.validate validator model
            in
                if (List.isEmpty validationErrors) then
                    model ! [ createPlayer model ]
                else
                    { model | errors = validationErrors } ! []

        Types.PlayerCreated (Err _) ->
            let
                newModel =
                    { model
                        | errors =
                            [ ( Types.Summary, "Error creating player" ) ]
                    }
            in
                newModel ! []

        Types.PlayerCreated (Ok newPlayer) ->
            let
                url =
                    "/players/" ++ (toString newPlayer.id)
            in
                model ! [ navigate url ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


updatePlayerField : (Player -> Player) -> Model -> ( Model, Cmd Msg )
updatePlayerField func model =
    let
        updatedPlayer =
            func model.player
    in
        { model | player = updatedPlayer } ! []


validator : Validator (Error FormField) Model
validator =
    Validate.all
        [ Validate.ifBlank
            (.player >> .firstName)
            ( Types.FirstName, "First name is required" )
        , Validate.ifBlank
            (.player >> .lastName)
            ( Types.LastName, "Last name is required" )
        ]
