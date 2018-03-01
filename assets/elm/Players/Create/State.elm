module Players.Create.State exposing (init, subscriptions, update)

import Players.Create.Types as Types exposing (Model, Msg)
import Common.Commands exposing (send)
import Common.Rest exposing (fetch, userRequest)
import Header.State


initialModel : Model
initialModel =
    { header = Header.State.initialModel
    , pageState = Types.Loading
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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
