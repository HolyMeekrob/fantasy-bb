module Leagues.Create.View exposing (view)

import Common.Views exposing (empty, layout, loading, title)
import Common.Views.Forms exposing (form)
import Header.View exposing (headerView)
import Html exposing (Html, div, section)
import Leagues.Create.Types as Types exposing (FormField, Model, Msg)


view : Model -> Html Msg
view model =
    layout
        (headerView Types.HeaderMsg model.header)
        (primaryView model)


primaryView : Model -> Html Msg
primaryView model =
    section
        []
        [ loadingOverlay model
        , title "Create League"
        , div
            []
            [ form
                ( "Submit", Types.SubmitForm )
                []
                (errors Types.Summary model)
                [ { id = "league-name"
                  , type_ = "text"
                  , label = "League Name"
                  , placeholder = "League name"
                  , value = model.name
                  , onInput = Types.SetName
                  , isRequired = True
                  , errors = errors Types.Name model
                  }
                ]
            ]
        ]


loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading

        _ ->
            empty


errors : FormField -> Model -> List String
errors field model =
    let
        fieldMatches =
            \( errorField, _ ) -> field == errorField
    in
        List.filter fieldMatches model.errors
            |> List.map Tuple.second
