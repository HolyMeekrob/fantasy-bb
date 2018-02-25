module Common.Views exposing (empty, layout, loading, title, titleWithEdit)

import FontAwesome as FA exposing (edit, iconWithOptions)
import Html exposing (Html, div, header, h1, main_, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


empty : Html msg
empty =
    text ""


layout : List (Html msg) -> Html msg -> Html msg
layout headerContent mainContent =
    div
        [ class "wrapper" ]
        [ header
            [ class "header" ]
            headerContent
        , main_
            [ class "content" ]
            [ mainContent ]
        ]


loading : Html msg
loading =
    div
        [ class "loading" ]
        [ div
            [ class "loading-indicator" ]
            [ div
                [ class "cube1" ]
                []
            , div
                [ class "cube2" ]
                []
            ]
        ]


title : String -> Html msg
title titleText =
    titleHelper titleText Nothing


titleWithEdit : String -> msg -> Html msg
titleWithEdit titleText onClickFunc =
    titleHelper titleText (Just onClickFunc)


titleHelper : String -> Maybe msg -> Html msg
titleHelper titleText onClickFunc =
    let
        icon =
            case onClickFunc of
                Nothing ->
                    []

                Just f ->
                    [ iconWithOptions
                        edit
                        FA.Solid
                        [ FA.Size FA.Small ]
                        [ class "clickable icon", onClick f ]
                    ]
    in
        div
            [ class "page-title" ]
        <|
            [ h1
                []
                [ text titleText ]
            ]
                ++ icon
