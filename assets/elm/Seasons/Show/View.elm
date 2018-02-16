module Seasons.Show.View exposing (view)

import Seasons.Show.Types as Types exposing (Model, Msg)
import Common.Views exposing (empty, layout, loading)
import Header.View exposing (headerView)
import Html exposing (Html, dd, div, dl, dt, h1, section, text)
import Html.Attributes exposing (class)


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
        , h1
            [ class "page-title" ]
            [ text "View Season" ]
        , div
            []
            [ dl
                []
                [ dt
                    []
                    [ text "Id" ]
                , dd
                    []
                    [ text (toString model.season.id) ]
                , dt
                    []
                    [ text "Title" ]
                , dd
                    []
                    [ text model.season.title ]
                , dt
                    []
                    [ text "Start" ]
                , dd
                    []
                    [ text model.season.start ]
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
