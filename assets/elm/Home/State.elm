module Home.State exposing (init, update, subscriptions)

import Common.Rest exposing (fetch, userRequest)
import Header.State
import Home.Types as Types exposing (Model, Msg)


init : ( Model, Cmd Msg )
init =
    let
        model =
            { header = Header.State.initialModel
            }
    in
        ( model, fetch userRequest Types.SetUser )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Types.HeaderMsg headerMsg ->
            let
                ( headerModel, headerCmd ) =
                    Header.State.update headerMsg model.header
            in
                ( { model | header = headerModel }
                , Cmd.map Types.HeaderMsg headerCmd
                )

        Types.SetUser (Err _) ->
            let
                header =
                    model.header

                headerModel =
                    { header | user = Nothing }
            in
                { model | header = headerModel } ! []

        Types.SetUser (Ok user) ->
            let
                header =
                    model.header

                headerModel =
                    { header | user = Just user }
            in
                { model | header = headerModel } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
