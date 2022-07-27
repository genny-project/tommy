import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/templates/fld_dropdown.dart';
import 'package:tommy/templates/fld_flag.dart';
import 'package:tommy/templates/fld_radio.dart';
import 'package:tommy/templates/tpl_appbar.dart';
import 'package:tommy/templates/tpl_cards_list_view.dart';
import 'package:tommy/templates/tpl_dashboard.dart';
import 'package:tommy/templates/tpl_date.dart';
import 'package:tommy/templates/tpl_detail_view.dart';
import 'package:tommy/templates/tpl_form.dart';
import 'package:tommy/templates/tpl_hidden_menu.dart';
import 'package:tommy/templates/tpl_hori.dart';
import 'package:tommy/templates/tpl_logo.dart';
import 'package:tommy/templates/tpl_sidebar.dart';
import 'package:tommy/templates/tpl_table.dart';
import 'package:tommy/templates/tpl_vert.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/templates/fld_richtext_editor.dart';
import 'package:tommy/widgets/timezone_widget.dart';

class TemplateHandler {
  // FocusNode focus;
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
        return GennyForm(entity: entity);

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

      case "TPL_DETAIL_VIEW1":
        return DetailView(entity: entity);

      case "TPL_CARDS_LIST_VIEW":
        return CardsListView(entity: entity);
      case "TPL_TABLE":
        return TableTpl(entity: entity);
      default:
        return Text(code);
    }
  }

  Widget getField(Ask ask, BuildContext context) {
    // return Text(ask.question.attribute.dataType.component);
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
          return DateTemplate(ask: ask);
          return CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.fromMillisecondsSinceEpoch(0),
              lastDate: DateTime.now(),
              onDateChanged: (value) {
                ask.answer(DateFormat('y-M-d').format(value));
              });
        }
      case "time_zone":
        BaseEntity entity = BridgeHandler.findByCode(ask.targetCode);
        return TimezoneWidget(entity: entity, ask: ask);
      case "button":
        {
          return TextButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                //TODO: find a better solution to simply waiting for focus to change arbitrarily
                Future.delayed(const Duration(seconds: 1), () {
                  BridgeHandler.evt(ask);
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
          BaseEntity entity = BridgeHandler.findByCode(ask.targetCode);
          return ListTile(
            title: Focus(
              onFocusChange: ((focus) {
                if (!focus) {
                  print("Changed focus.");
                  ask.answer(entity.findAttribute(ask.attributeCode).valueString);
                }
              }),
              child: TextFormField(
                  onChanged: (value) {
                    entity.findAttribute(ask.attributeCode).valueString = value;
                  },
                  initialValue:
                      entity.findAttribute(ask.attributeCode).valueString,
                  autovalidateMode: AutovalidateMode.always,
                  validator: BridgeHandler.createValidator(ask),
                  onFieldSubmitted: (value) {
                    ask.answer(value);
                  },
                  decoration: InputDecoration(
                    
                    suffixIcon: ask.mandatory ? Icon(Icons.info) : SizedBox(),
                    labelText:
                        "${ask.name} ${ask.question.attribute.dataType.component}",
                  )),
            ),
          );
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
    return IconButton(
        onPressed: () {
          /* # # # # #
          I would use the Geoff logger here but the standard dart print is far better at printing GRPC objects
          # # # # # */
          // ignore: avoid_print
          print("Attribute $attribute");
        },
        icon: const Icon(Icons.error));
  }
}
