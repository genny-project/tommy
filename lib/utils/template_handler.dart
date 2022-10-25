import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/templates/fld_date.dart';
import 'package:tommy/templates/fld_dropdown.dart';
import 'package:tommy/templates/fld_flag.dart';
import 'package:tommy/templates/fld_radio.dart';
import 'package:tommy/templates/fld_richtext_editor.dart';
import 'package:tommy/templates/fld_text.dart';
import 'package:tommy/templates/tpl_add_items.dart';
import 'package:tommy/templates/tpl_appbar.dart';
import 'package:tommy/templates/tpl_avatar.dart';
import 'package:tommy/templates/tpl_bell.dart';
import 'package:tommy/templates/tpl_cards_list_view.dart';
import 'package:tommy/templates/tpl_dashboard.dart';
import 'package:tommy/templates/tpl_detail_view.dart';
import 'package:tommy/templates/tpl_form.dart';
import 'package:tommy/templates/tpl_hidden_menu.dart';
import 'package:tommy/templates/tpl_hori.dart';
import 'package:tommy/templates/tpl_horizontal_cards.dart';
import 'package:tommy/templates/tpl_logo.dart';
import 'package:tommy/templates/tpl_process.dart';
import 'package:tommy/templates/tpl_sidebar.dart';
import 'package:tommy/templates/tpl_table.dart';
import 'package:tommy/templates/tpl_vert.dart';
import 'package:tommy/templates/tpl_vertical_cards.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/widgets/timezone_widget.dart';

class TemplateHandler {
  // FocusNode focus;
  static Map<String, BuildContext> contexts = {};
  TemplateHandler();
  static Widget getTemplate(String code, BaseEntity entity) {
    switch (code) {
      case "TPL_VERT":
        return Vert(entity: entity);

      case "TPL_HORI":
        return Hori(entity: entity);

      case "TPL_CONTENT":
        return Container(
          child: entity.findAttribute('PRI_LOC1').getPcmWidget(),
        );

      case "TPL_DASHBOARD":
        return Vert(
          entity: entity,
        );

      case "TPL_PROGRESS_BAR":
        return const SizedBox();

      case "TPL_FORM":
        //similar to the table oddity, this key absolutely ensures that the form instance is brand new
        
        //had to rework this because using a unique key on every build was messing with the state management
        //of the form. made it control like a cow in a shopping trolley
        return GennyForm(entity: entity,  key: Key("${BridgeHandler
        .askData[entity.findAttribute("PRI_QUESTION_CODE").valueString]?.hashCode}",));

      case "TPL_LOGO":
        return Logo(
          entity: entity,
        );

      case "TPL_HIDDEN_MENU":
        return HiddenMenu(entity: entity);

      case "TPL_HEADER_1":
        return AppBarTpl(entity: entity);

      case "TPL_SIDEBAR_1":
        return Sidebar(entity: entity);

      case "TPL_DASHBOARD_1":
        return Dashboard(entity: entity);

      case "TPL_DETAIL_VIEW":
        return DetailView(entity: entity);

      case "TPL_CARDS_LIST_VIEW":
        return CardsListView(entity: entity);
      case "TPL_TABLE":
        //providing key because without it, it doesnt know to overwrite itself. weird one.
        //note for later: maybe do what i did with the form key?
        //as it stands the focus doesnt really matter too much right now but it is worth keeping in mind
        return TableTpl(entity: entity, key: Key(entity.hashCode.toString()),);
      
      case "TPL_ADD_ITEMS":
        return AddItemsTpl(entity: entity);
      case "TPL_BELL":
        return BellTpl(entity: entity);
      case "TPL_AVATAR":
        return AvatarTpl(entity: entity);
      case "TPL_HORIZONTAL_CARDS":
        return HorizontalCardsTpl(entity: entity);
      case "TPL_PROCESS":
        //keep the key solution from the table in mind, might need to use it for the bucket view too, if any problems present
        return ProcessTpl(entity: entity);
      case "TPL_VERTICAL_CARDS":
        return VerticalCardsTpl(entity: entity);
      default:
        return Text(code);
    }
  }

  Widget getField(Ask ask, BuildContext context, FocusNode fNode) {
  switch (ask.question.attribute.dataType.component) {
      case "radio":
        {
          return RadioField(ask: ask);
        }
      case "dropdown":
        {
          return DropdownField(ask: ask);
        }
      case "flag":
        {
          return FlagField(ask: ask);
        }
      case "date":
        {
          return DateField(ask: ask);
        }
      case "time_zone":
        return TimezoneWidget(ask: ask);
      case "button":
        {
          return TextButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                //TODO: find a better solution to simply waiting for focus to change arbitrarily
                Future.delayed(const Duration(seconds: 2), () {
                  BridgeHandler.askEvt(ask);
                });
              },
              child: Text(ask.name));
        }
      case "richtext_editor":
        {
          return RichtextEditor(
            ask: ask,
          );
        }

      default:
        {

          return GennyTextField(ask: ask,); 
        }
    }
  }

  static String fixLnkAndPri(String value) {
    return value.split('__')[0].replaceFirst('_', '');
  }

  static Widget attributeWidget(EntityAttribute attribute) {
    if (!attribute.attributeCode.startsWith("PRI_LOC")) {
      return const SizedBox();
    }
    if (attribute.valueString.startsWith("PCM_")) {
      return attribute.getPcmWidget();
    }
    return Column(
      children: [
        
        IconButton(
            onPressed: () {
              /* # # # # #
              I would use the Geoff logger here but the standard dart print is far better at printing GRPC objects
              # # # # # */
              // ignore: avoid_print
              print("Attribute $attribute");
            },
            icon: const Icon(Icons.error)),
      Text(attribute.valueString.toString())
      ],
    );
  }
}
