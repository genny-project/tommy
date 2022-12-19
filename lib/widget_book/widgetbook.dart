import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/templates/fld_text.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tommy/template_library.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/generated/baseentity.pb.dart';

class WidgetbookHotReload extends StatelessWidget {
  final String file;
  const WidgetbookHotReload(this.file, {Key? key}) : super(key: key);
  static BuildContext? bcontext;
  static Widgetbook<ThemeData> wb = Widgetbook.material(
      categories: [
        WidgetbookCategory(
          name: 'material',
          widgets: [
            WidgetbookComponent(
              name: 'Templates',
              useCases: [
                getTplUseCase(name: "tpl_avatar", templateCode: "TPL_AVATAR"),
                getTplUseCase(name: "tpl_form", templateCode: "TPL_FORM"),
                getTplUseCase(name: "tpl_process", templateCode: "TPL_PROCESS"),
                getTplUseCase(name: "tpl_bell", templateCode: "TPL_BELL"),
                getTplUseCase(
                    name: "tpl_hidden_menu", templateCode: "TPL_HIDDEN_MENU"),
                getTplUseCase(name: "tpl_sidebar", templateCode: "TPL_SIDEBAR_1"),
                getTplUseCase(
                    name: "tpl_action_button",
                    templateCode: "TPL_ACTION_BUTTON"),
                getTplUseCase(
                    name: "tpl_cards_list_view",
                    templateCode: "TPL_CARDS_LIST_VIEW"),
                getTplUseCase(name: "tpl_hori", templateCode: "TPL_HORI"),
                getTplUseCase(name: "tpl_table", templateCode: "TPL_TABLE"),
                getTplUseCase(
                    name: "tpl_add_items", templateCode: "TPL_ADD_ITEMS"),
                getTplUseCase(
                    name: "tpl_dashboard", templateCode: "TPL_DASHBOARD"),
                getTplUseCase(
                    name: "tpl_horizontal_cards",
                    templateCode: "TPL_HORIZONTAL_CARDS"),
                getTplUseCase(name: "tpl_vert", templateCode: "TPL_VERT"),
                getTplUseCase(name: "tpl_appbar", templateCode: "TPL_HEADER_1"),
                getTplUseCase(
                    name: "tpl_detail_view", templateCode: "TPL_DETAIL_VIEW"),
                getTplUseCase(name: "tpl_logo", templateCode: "TPL_LOGO"),
                getTplUseCase(
                    name: "tpl_vertical_cards",
                    templateCode: "TPL_VERTICAL_CARDS"),
              ],
            ),
            WidgetbookComponent(name: "Fields", useCases: [
              getFieldUseCase(name: "fld_date", componentCode: "date"),
              getFieldUseCase(name: "fld_dropdown", componentCode: "dropdown"),
              getFieldUseCase(name: "fld_flag", componentCode: "flag"),
              getFieldUseCase(name: "fld_radio", componentCode: "radio"),
              getFieldUseCase(name: "fld_richtext_editor", componentCode: "richtext_editor"),
              getFieldUseCase(name: "fld_text", componentCode: "text"),
              getFieldUseCase(name: "fld_timezone", componentCode: "time_zone"),
            ]),
          ],
        ),
      ],
      devices: [
        Apple.iPhone6,
        Apple.iPhone7,
        Apple.iPhone8,
        Apple.iPhoneX,
        Apple.iPhone11,
        Apple.iPhone12,
        Apple.iPad10Inch,
        Apple.iPadMini,
        Apple.iPadPro12inch
      ],
      appInfo: AppInfo(name: 'Tommy'),
      themes: [
        WidgetbookTheme(name: 'Bridge Theme', data: BridgeHandler.theme),
        WidgetbookTheme(
          name: 'Dark',
          data: ThemeData.dark(),
        ),
      ],
    );
  @override
  Widget build(BuildContext context) {
    bcontext = context;
    return wb;
  }
}
WidgetbookUseCase getFieldUseCase({required String name, required String componentCode}) {
  List<Ask> asks = [];
  asks = BridgeHandler.askData.values.where((element) {
    for(Ask childAsk in element.childAsks) {
      if(childAsk.question.attribute.dataType.component == componentCode) {
        asks.add(childAsk);
      }
    }
    return element.question.attribute.dataType.component == componentCode;
  },).toList();
  Ask ask;

  return WidgetbookUseCase(name: name, builder: ((context) {
      String rawAskData = context.knobs.text(
            label: "Raw Ask",
            description: "Enter Proto3 JSON data",
            initialValue: "");
    if(asks.isNotEmpty && rawAskData.isEmpty) {
        ask = context.knobs.options(
                  label: "BaseEntities with associated template",
                  options: List.generate(
                      asks.toSet().length,
                      (index) => Option(
                          //labelling the option with the index is necessary as any duplicate labels will cause an error
                          label: (asks[index].attributeCode + " " + index.toString()), value: asks[index])));
    } else {
      ask = Ask()..mergeFromProto3Json(rawAskData.isNotEmpty ? jsonDecode(rawAskData) : {});
    }
    
    return TemplateHandler.getField(ask, context);
  }));
}
WidgetbookUseCase getTplUseCase(
    {required String name, required String templateCode}) {
  return WidgetbookUseCase(
      name: name,
      builder: (context) {
        List<BaseEntity> entities = BridgeHandler.beData.values
            .where((element) => element
                .findAttribute("PRI_TEMPLATE_CODE")
                .valueString
                .contains(templateCode))
            .toList();
        // return Text(BridgeHandler.askData.toString());
        String rawBeValue = context.knobs.text(
            label: "Raw Base Entity",
            description: "Enter Proto3 JSON data",
            initialValue: "");
        BaseEntity be;
        if (entities.isNotEmpty) {
          be = rawBeValue.isEmpty
              ? context.knobs.options(
                  label: "BaseEntities with associated template",
                  options: List.generate(
                      entities.length,
                      (index) => Option(
                          label: entities[index].code, value: entities[index])))
              : BaseEntity.create()
            ..mergeFromProto3Json(
                jsonDecode(rawBeValue.isEmpty ? "{}" : rawBeValue));
        } else {
          be = BaseEntity.create();
        }
        // return Text(context.knobs.toString());
        return ListView(children: [TemplateHandler.getTemplate(templateCode, be)]);
      });
}
