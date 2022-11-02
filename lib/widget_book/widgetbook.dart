import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tommy/template_library.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/generated/baseentity.pb.dart';

class WidgetbookHotReload extends StatelessWidget {
  final String file;
  const WidgetbookHotReload(this.file, {Key? key}) : super(key: key);
  static final String thing = "yeahhh";
  static BuildContext? bcontext;
  static Widgetbook<ThemeData> wb = Widgetbook.material(
      categories: [
        WidgetbookCategory(
          name: 'material',
          widgets: [
            WidgetbookComponent(
              name: 'Templates',
              useCases: [
                getUseCase(name: "tpl_avatar", templateCode: "TPL_AVATAR"),
                getUseCase(name: "tpl_form", templateCode: "TPL_FORM"),
                getUseCase(name: "tpl_process", templateCode: "TPL_PROCESS"),
                getUseCase(name: "tpl_bell", templateCode: "TPL_BELL"),
                getUseCase(
                    name: "tpl_hidden_menu", templateCode: "TPL_HIDDEN_MENU"),
                getUseCase(name: "tpl_sidebar", templateCode: "TPL_SIDEBAR_1"),
                getUseCase(
                    name: "tpl_action_button",
                    templateCode: "TPL_ACTION_BUTTON"),
                getUseCase(
                    name: "tpl_cards_list_view",
                    templateCode: "TPL_CARDS_LIST_VIEW"),
                getUseCase(name: "tpl_hori", templateCode: "TPL_HORI"),
                getUseCase(name: "tpl_table", templateCode: "TPL_TABLE"),
                getUseCase(
                    name: "tpl_add_items", templateCode: "TPL_ADD_ITEMS"),
                getUseCase(
                    name: "tpl_dashboard", templateCode: "TPL_DASHBOARD"),
                getUseCase(
                    name: "tpl_horizontal_cards",
                    templateCode: "TPL_HORIZONTAL_CARDS"),
                getUseCase(name: "tpl_vert", templateCode: "TPL_VERT"),
                getUseCase(name: "tpl_appbar", templateCode: "TPL_HEADER_1"),
                getUseCase(
                    name: "tpl_detail_view", templateCode: "TPL_DETAIL_VIEW"),
                getUseCase(name: "tpl_logo", templateCode: "TPL_LOGO"),
                getUseCase(
                    name: "tpl_vertical_cards",
                    templateCode: "TPL_VERTICAL_CARDS"),
              ],
            ),
          ],
        ),
      ],
      devices: [
        Apple.iPhone6,
        Apple.iPhone7,
        Apple.iPhone8,
        Apple.iPhoneX,
        Apple.iPhone11,
        Apple.iPhone12
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

WidgetbookUseCase getUseCase(
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
        return TemplateHandler.getTemplate(templateCode, be);
      });
}
