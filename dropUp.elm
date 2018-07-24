module DropUp exposing (..)

{-|

This package helps you create a dropdown list with multiselect

-}

import Html exposing (Html, Attribute)
import Html.Attributes as Attr

type alias State =
    { title : String
    , fullList : List String
    , checkedlist : List String
    , displayDropDown : Bool
    }


dropDownInit : String -> List String -> State
dropDownInit displayText itemsList =
    { title = displayText
    , fullList = itemsList
    , checkedList = []
    , displayDropDown = False
    }

view : State -> Html msg
view state =
    Html.div
        [ Attr.style
            [ ( "display", "flex" ), ( "flex-direction", "column" ), ( "justify-content", "center" )
            , ( "margin-right", "2%" ), ( "margin-left", "2%" ), ( "width", "90%" ), ( "word-wrap", "break-word" )
            , ( "align-self", "flex-start" ), ( "position", "relative" ) ]
        ]
        [ Html.div []
            [ Html.button
                [ Attr.style
                    [ ( "width", "100%" )
                    , ( "text-overflow", "ellipsis" )
                    , ( "overflow", "hidden" )
                    , ( "font-style", "italic" )
                    ]
                , Attr.class "btn btn-default btn-responsive"
                , onClick toggleDropUp
                ]
                [ Html.text state.title ]
            , if state.displayDropDown == True then
                Html.div
                    [ Attr.style ([( "display", "flex" )
                              , ( "justify-content", "center" )
                              , ( "width", "100%" ), ( "padding-top", "4px" ) ]) ]
                    [ viewDropUpButton
                        selectAll
                        "Select All"
                        (List.length state.fullList /= List.length state.checkedList)
                    , viewDropUpButton
                        hideAll
                        "Hide All"
                        (state.checkedList /= [])
                    ]
              else
                Html.text ""
            ]
        , viewChecklist
            state.displayDropDown
            state.checkedList
            state.fullList
        ]

viewChecklist : Bool -> List String -> List String -> Html msg
viewChecklist display listToShow completeList =
    let
        makeItem item =
            Html.div
                [ Attr.style
                    [ ( "padding", "10px 10px 0px" )
                    , ( "background-color", "white" )
                    ]
                ]
                [ Html.span []
                    [ Html.input
                        [ Attr.type_ "checkbox"
                        , Attr.style [ ( "margin-right", "5px" ) ]
                        , Attr.checked (List.member item listToShow)
                        , onClick toggleItem item
                        ]
                        []
                    ]
                , Html.text item
                ]
    in
    if display == True then
        Html.div
            [ Attr.style css.popUpMenu
            ]
            (List.map makeItem completeList)
    else
        Html.text ""

viewDropUpButton : msg -> String -> Bool -> Html msg
viewDropUpButton clickMsg displayText isWorking =
    if isWorking then
        Html.button
            [ Attr.class "btn btn-basic"
            , Attr.style css.dropUpButton
            , onClick clickMsg
            ]
            [ Html.text displayText ]
    else
        Html.button
            [ Attr.class "btn btn-basic disabled"
            , Attr.style css.dropUpButton
            ]
            [ Html.text displayText ]

toggleDropUp : State -> State
toggleDropUp state =
    {state | displayDropDown = not state.displayDropDown}

selectAll : State -> State
selectAll state =
    {state | checkedList = state.fullList}

hideAll : State -> State
hideAll state =
    {state | checkedList = []}


toggleItem : String -> State -> State
toggleItem item state =
    if List.member item state.checkedList then
        {state | checkedList = List.filter (\s -> item /= s ) state.checkedList}
    else
        {state | listToShow = [item] ++ state.checkedList }

css =
    { popUpMenu =
        [ ( "max-height", "500px" )
        , ( "min-width", "100%" )
        , ( "overflow-y", "auto" )
        , ( "border", "1px solid #d0d0d0" )
        , ( "position", "absolute" )
        , ( "bottom", "63px" )
        , ( "z-index", "2" )
        ]
    , dropUpButton =
        [ ( "width", "50%" )
        , ( "height", "25px" )
        , ( "text-overflow", "ellipsis" )
        , ( "overflow", "hidden" )
        , ( "padding", "0px" )
        , ( "font-size", "12px" )
        , ( "border-radius", "0px" )
        , ( "border", "1px solid #e0e0e0" )
        , ( "background-color", "white" )
        ]
    }









