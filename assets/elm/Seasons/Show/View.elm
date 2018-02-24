module Seasons.Show.View exposing (view)

import Seasons.Show.Types as Types
    exposing
        ( FormField
        , Model
        , Msg
        , Player
        , Season
        )
import Common.Date exposing (dateToString)
import Common.Views exposing (empty, layout, loading)
import Common.Views.Forms exposing (form)
import Common.Views.Text exposing (playerName)
import Editable exposing (Editable)
import FontAwesome as FA exposing (edit, iconWithOptions)
import Header.View exposing (headerView)
import Html exposing (Html, a, dd, div, dl, dt, h1, li, section, text, ul)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)


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
            [ class "page-title"
            , onClick Types.EditSeason
            ]
            [ text "View Season "
            , iconWithOptions
                edit
                FA.Solid
                [ FA.Size FA.ExtraSmall ]
                [ class "clickable" ]
            ]
        , season model
        , houseguests model.season
        ]


season : Model -> Html Msg
season model =
    if (Editable.isReadOnly model.season) then
        viewSeason (Editable.value model.season)
    else
        editSeason model


viewSeason : Season -> Html Msg
viewSeason season =
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
                [ Maybe.map dateToString season.start
                    |> Maybe.withDefault ""
                    |> text
                ]
            ]
        ]


editSeason : Model -> Html Msg
editSeason model =
    let
        season =
            Editable.value model.season
    in
        div
            []
            [ form
                ( "Save", Types.SubmitForm )
                [ ( "Cancel", Types.CancelEdit ) ]
                (errors Types.Summary model)
                [ { id = "season-title"
                  , type_ = "text"
                  , label = "Title"
                  , placeholder = "Season title"
                  , value = season.title
                  , onInput = Types.SetTitle
                  , isRequired = True
                  , errors = errors Types.Title model
                  }
                , { id = "season-start"
                  , type_ = "date"
                  , label = "Start date"
                  , placeholder = "Season start date"
                  , value =
                        season.start
                            |> Maybe.map dateToString
                            |> Maybe.withDefault ""
                  , onInput = Types.SetStart
                  , isRequired = True
                  , errors = errors Types.Start model
                  }
                ]
            ]


houseguests : Editable Season -> Html Msg
houseguests season =
    case season of
        Editable.Editable _ _ ->
            empty

        Editable.ReadOnly seasonVal ->
            div
                []
                [ text "Houseguests"
                , ul
                    []
                    (List.map viewHouseguest seasonVal.players)
                ]


viewHouseguest : Player -> Html Msg
viewHouseguest player =
    let
        name =
            playerName player.firstName player.lastName player.nickname

        url =
            "/players/" ++ toString player.id
    in
        li
            []
            [ a
                [ href url ]
                [ text name ]
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
