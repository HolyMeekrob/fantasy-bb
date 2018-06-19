module Teams.Show.View exposing (view)

import Common.Views exposing (empty, layout, loading, title)
import Header.View exposing (headerView)
import Html exposing (Html, section)
import Teams.Show.Types as Types exposing (Model, Msg, Team)


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
        , title model.team.name
        , content model
        ]


content : Model -> Html Msg
content model =
    empty


loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading

        _ ->
            empty
