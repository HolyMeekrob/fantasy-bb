module Seasons.Show.View exposing (view)

import Seasons.Show.Types as Types exposing (Houseguest, Model, Msg, Season)
import Common.Views exposing (empty, layout, loading)
import Header.View exposing (headerView)
import Html exposing (Html, a, dd, div, dl, dt, h1, li, section, text, ul)
import Html.Attributes exposing (class, href)


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
        , seasonInfo model.season
        , houseguests model.season.houseguests
        ]

seasonInfo : Season -> Html Msg
seasonInfo season =
    div
        []
        [ dl
            []
            [ dt
                []
                [ text "Id" ]
            , dd
                []
                [ text (toString season.id) ]
            , dt
                []
                [ text "Title" ]
            , dd
                []
                [ text season.title ]
            , dt
                []
                [ text "Start" ]
            , dd
                []
                [ text season.start ]
            ]
        ]

houseguests : List Houseguest -> Html Msg
houseguests houseguests =
    div
        []
        [ text "Houseguests"
        , ul
            []
            (List.map houseguestInfo houseguests)
        ]

houseguestInfo : Houseguest -> Html Msg
houseguestInfo houseguest =
    let
        nickname =
            case houseguest.nickname of
                Just name ->
                    "\"" ++ name ++ "\""
                Nothing ->
                    ""
        name =
            [houseguest.firstName, nickname, houseguest.lastName]
            |> List.filter (\str -> not (String.isEmpty str))
            |> String.join " "

        url = "/houseguests/" ++ toString houseguest.id
    in
        
    li
        []
        [a
            [href url]
            [text name]
        ]


loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading

        _ ->
            empty
