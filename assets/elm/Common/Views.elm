module Common.Views exposing (..)

import Date exposing (Date)
import Html exposing (Html, div, header, main_, text)
import Html.Attributes exposing (class)


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


showMaybeDate : Maybe Date -> String
showMaybeDate date =
    case date of
        Just d ->
            showDate d

        Nothing ->
            ""


showDate : Date -> String
showDate date =
    let
        year =
            Date.year date

        month =
            monthToInt (Date.month date)

        day =
            Date.day date
    in
        String.padLeft 4 '0' (toString year)
            ++ "-"
            ++ String.padLeft 2 '0' (toString month)
            ++ "-"
            ++ String.padLeft 2 '0' (toString day)


monthToInt : Date.Month -> Int
monthToInt month =
    case month of
        Date.Jan ->
            1

        Date.Feb ->
            2

        Date.Mar ->
            3

        Date.Apr ->
            4

        Date.May ->
            5

        Date.Jun ->
            6

        Date.Jul ->
            7

        Date.Aug ->
            8

        Date.Sep ->
            9

        Date.Oct ->
            10

        Date.Nov ->
            11

        Date.Dec ->
            12
