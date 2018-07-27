module DropUp exposing
    ( Config
    , Direction (Down, Up)
    , State
    , config
    , customConfig
    , initialState
    , view
    )

{-| This package helps you create a simple dropdown with a checklist that allows
you to select multiple options at once.

# State

@docs State, initialState


# Configuration

@docs Config, config, customConfig


# View

@docs view

-}
import Html exposing (Html, button, div, input, span, text)
import Html.Attributes exposing (checked, style, type_)
import Html.Events exposing (onClick)



-- STATE


{-| Tracks whether the dropdown checklist is displayed.
-}
type alias State =
    { displayDropDown : Bool
    }


{-| Create a dropdown state.
-}
initialState : State
initialState =
    { displayDropDown = False
    }



-- CONFIG


{-| Configuration for your dropdown.

Note: Your configuration should only appear in your view code, not your model.
-}
type Config dataType msg
    = Config
        { dataToMsg : List ( dataType, Bool ) -> msg
        , dataToString : dataType -> String
        , displayCheckAllButtons : Bool
        , displayDirection : Direction
        , displayText : String
        , stateToMsg : State -> msg
        }

{-| Create the 'Config' for your 'view' function.

For example:

    import DropUp

    type Msg = SetDropDownState DropUp.State | SetItems (List (String, Bool)) | ...

    config : DropUp.Config String Msg
    config =
        DropUp.config
            { displayText = "Example DropDown"
            , stateToMsg = SetDropDownState
            , dataToMsg = SetItems
            }

You provide the following information for your dropdown configuration:

  - 'displayText' &mdash; text that will be displayed on the dropdown button
  - 'stateToMsg' &mdash; a way to send new dropdown states to your app as messages
  - 'dataToMsg' &mdash; a way to send new item lists to your app as messages
-}
config :
    { displayText : String
    , stateToMsg : State -> msg
    , dataToMsg : List ( String, Bool ) -> msg
    }
    -> Config String msg
config { displayText, stateToMsg, dataToMsg } =
    Config
        { displayText = displayText
        , stateToMsg = stateToMsg
        , dataToMsg = dataToMsg
        , dataToString = \data -> data
        , displayDirection = Up
        , displayCheckAllButtons = False
        }


{-| This is just like 'config',
but you can specify more fields for the dropdown.

In addition to the information needed for config, you also provide:

  - 'dataToString' &mdash; A function to convert one of the items from your checklist to
    a string for display purposes (such as (\s -> toString(s))
  - 'dataType' &mdash; This is the variable type of each item in your checklist.
    For example, if the items in your dropdown are integers, dataType should be Int
  - 'displayDirection' &mdash; The direction that the checklist will be displayed (DropUp.Up or DropUp.Down)
-}
customConfig :
    { displayText : String
    , stateToMsg : State -> msg
    , dataToMsg : List ( dataType, Bool ) -> msg
    , dataToString : dataType -> String
    , displayDirection : Direction
    , displayCheckAllButtons : Bool
    }
    -> Config dataType msg
customConfig { displayText, stateToMsg, dataToMsg, dataToString, displayDirection, displayCheckAllButtons } =
    Config
        { displayText = displayText
        , stateToMsg = stateToMsg
        , dataToMsg = dataToMsg
        , dataToString = dataToString
        , displayDirection = displayDirection
        , displayCheckAllButtons = displayCheckAllButtons
        }


{-| The direction that the checklist will be displayed.
-}
type Direction
    = Up
    | Down



-- VIEW


{-| Take a list of data and turn it into a multi-select dropdown. The 'Config' argument
is the configuration for the dropdown. The 'State' argument describes whether the dropdown
menu is displayed or not.

The data argument is the complete list of (item, Bool) pairs to display
in the dropdown. The first entry of each pair is what is displayed in the dropdown, and
the second entry is whether or not it is checked.

    For example: data = [("Option 1", False), ("Option 2", True), ("Option 3", True)]

Note: The 'State' should be in your 'Model'. The 'Config' and data for the dropdown
should live in your 'view' code.
-}
view : Config dataType msg -> State -> List ( dataType, Bool ) -> Html msg
view (Config config) state data =
    div
        [ style [ ( "position", "relative" ) ] ]
        [ button
            [ style css.toggleButton
            , onClick (toggleDisplay state |> config.stateToMsg)
            ]
            [ text config.displayText ]
        , viewButtonsWrapper
            (Config config)
            data
            state
        , viewChecklist
            (Config config)
            data
            state
        ]


viewChecklist : Config dataType msg -> List ( dataType, Bool ) -> State -> Html msg
viewChecklist (Config config) data state =
    let
        cssStyle =
            if config.displayDirection == Down then
                css.checklist ++ css.checklistBelow
            else
                css.checklist ++ css.checklistAbove
    in
    if state.displayDropDown == True then
        div
            [ style cssStyle ]
            (List.map (viewRow config.dataToMsg config.dataToString data) data)
    else
        text ""


viewRow : (List ( dataType, Bool ) -> msg) -> (dataType -> String) -> List ( dataType, Bool ) -> ( dataType, Bool ) -> Html msg
viewRow dataToMsg dataToString data ( item, isChecked ) =
    div
        [ style
            [ ( "margin", "10px 10px 0px" )
            , ( "background-color", "white" )
            ]
        ]
        [ span []
            [ input
                [ type_ "checkbox"
                , style [ ( "margin-right", "5px" ) ]
                , checked isChecked
                , onClick (toggleItem ( item, isChecked ) data |> dataToMsg)
                ]
                []
            ]
        , text (dataToString item)
        ]


viewButtonsWrapper : Config dataType msg -> List ( dataType, Bool ) -> State -> Html msg
viewButtonsWrapper (Config config) data state =
    let
        cssStyle =
            if config.displayDirection == Up then
                css.checkAllButtons
            else
                css.checkAllButtons ++ css.checkAllButtonsAbove
    in
    if state.displayDropDown && config.displayCheckAllButtons then
        div [ style [ ( "position", "absolute" ), ( "width", "100%" ) ] ]
            [ viewCheckAllButton cssStyle data config.dataToMsg
            , viewUncheckAllButton cssStyle data config.dataToMsg
            ]
    else
        text ""


viewCheckAllButton : List ( String, String ) -> List ( dataType, Bool ) -> (List ( dataType, Bool ) -> msg) -> Html msg
viewCheckAllButton cssStyle data dataToMsg =
    button
        [ style cssStyle
        , onClick (checkAll data |> dataToMsg)
        ]
        [ text "Check All" ]


viewUncheckAllButton : List ( String, String ) -> List ( dataType, Bool ) -> (List ( dataType, Bool ) -> msg) -> Html msg
viewUncheckAllButton cssStyle data dataToMsg =
    button
        [ style (cssStyle ++ [ ( "border-left", "none" ) ])
        , onClick (uncheckAll data |> dataToMsg)
        ]
        [ text "Uncheck All" ]



-- HELPERS


{-| Toggle whether the dropdown is displayed.
-}
toggleDisplay : State -> State
toggleDisplay state =
    { state | displayDropDown = not state.displayDropDown }


{-| Check all items.
-}
checkAll : List ( dataType, Bool ) -> List ( dataType, Bool )
checkAll data =
    List.map (\( item, isChecked ) -> ( item, True )) data


{-| Uncheck all items.
-}
uncheckAll : List ( dataType, Bool ) -> List ( dataType, Bool )
uncheckAll data =
    List.map (\( item, isChecked ) -> ( item, False )) data


{-| Toggle whether an item is checked.
-}
toggleItem : ( dataType, Bool ) -> List ( dataType, Bool ) -> List ( dataType, Bool )
toggleItem ( item, isChecked ) data =
    List.map
        (\( entry, checked ) ->
            if entry == item then
                ( entry, not checked )
            else
                ( entry, checked )
        )
        data



-- CSS


css :
    { checklist : List ( String, String )
    , checklistAbove : List ( String, String )
    , checklistBelow : List ( String, String )
    , checkAllButtons : List ( String, String )
    , toggleButton : List ( String, String )
    , checkAllButtonsAbove : List ( String, String )
    }
css =
    { toggleButton =
        [ ( "width", "100%" )
        , ( "text-overflow", "ellipsis" )
        , ( "overflow", "hidden" )
        , ( "background-color", "#eeeeee" )
        , ( "border", "1px solid #d0d0d0" )
        , ( "font-size", "16px" )
        , ( "padding-top", "4px" )
        , ( "padding-bottom", "4px" )
        ]
    , checklist =
        [ ( "max-height", "200px" )
        , ( "overflow-y", "auto" )
        , ( "word-wrap", "break-word" )
        , ( "border", "1px solid #e0e0e0" )
        , ( "z-index", "2" )
        , ( "margin-top", "0px" )
        , ( "left", "0px" )
        , ( "right", "0px" )
        , ( "padding-bottom", "10px" )
        ]
    , checklistAbove =
        [ ( "position", "absolute" )
        , ( "bottom", "28px" )
        , ( "border-bottom", "none" )
        ]
    , checklistBelow =
        [ ( "border-top", "none" )
        ]
    , checkAllButtonsAbove =
        [ ( "position", "relative" )
        , ( "bottom", "53px" )
        , ( "border-top", "1px solid #d0d0d0" )
        , ( "border-bottom", "none" )
        ]
    , checkAllButtons =
        [ ( "width", "50%" )
        , ( "height", "25px" )
        , ( "white-space", "nowrap" )
        , ( "text-overflow", "ellipsis" )
        , ( "overflow", "hidden" )
        , ( "font-size", "11px" )
        , ( "border-radius", "0px" )
        , ( "border", "1px solid #d0d0d0" )
        , ( "border-top", "none" )
        , ( "background-color", "white" )
        ]
    }
