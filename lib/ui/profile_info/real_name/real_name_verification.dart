import 'dart:io';

import 'package:api/data/provider/input_validation_provider.dart';
import 'package:api/entity/identity_status.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/profile_info/real_name/real_name_verification_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class RealNameVerification extends StatefulWidget {
  @override
  _RealNameVerificationState createState() => _RealNameVerificationState();
}

class _RealNameVerificationState extends BaseState<RealNameVerification> {
  var _vm = RealNameVerificationViewModel();
  TextEditingController _realNameController = TextEditingController(), _icNoController = TextEditingController(), _icNumberController = TextEditingController();
  var isButtonEnabled = false, isTextFieldEnabled = false, isShowICNo;
  var buttonText;
  InputValidationProvider validate = new InputValidationProvider();
  File? uploadImage;
  bool isEdit = false;

  // waiting verify = 0, approve = 1, reject = 2, default (first time user) = 4
  int _identityStatus = 4;

  @override
  void initState() {
    _getState();
    super.initState();
  }

  Widget build(BuildContext context) {
    print(_identityStatus);
    return ProviderWidget<RealNameVerificationViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(
              appBar: CustomAppBar(
                title: getTranslatedText("ic_no"),
              ),
              body: Container(
                margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 20.auto),
                child: Column(
                  children: [
                    _buildTextFormField("realname", "enter_realname_hint", _realNameController, false, isRealname: true),
                    Visibility(
                      //identity status ==0, show when isEdit
                      //identity status ==1, always hide
                      //identity status ==2 ,show
                      //identity status ==4, hide
                      // show when icVerification is true, and if identity status not approved
                      visible: (_vm.config.icVerification ?? true) && ((_identityStatus == 0 && isEdit) || _identityStatus == 2 || _identityStatus == 4),
                      // _vm.userProfile.identityFormStatus == IdentityStatus.Reject ||
                      //     (_vm.userProfile.identityFormStatus == IdentityStatus.WaitingVerify &&
                      //         (isEdit || _vm.userProfile.identityFormId == null)),
                      child: _buildICNumberTextFormField(),
                    ),
                    Visibility(
                      visible: (_vm.config.icVerificationUpload ?? false) && ((_identityStatus == 0 && isEdit) || _identityStatus == 2 || _identityStatus == 4),
                      // _vm.userProfile.identityFormStatus == IdentityStatus.Reject ||
                      //     (_vm.userProfile.identityFormStatus == IdentityStatus.WaitingVerify &&
                      //         (isEdit || _vm.userProfile.identityFormId == null)),
                      child: _buildUploadImageButton(),
                    ),
                    _buildDoneButton(),
                    _buildFooterText()
                  ],
                ),
              ));
        });
  }

  _buildUploadDocColumn() => Column(
        children: [
          _buildTextFormField("realname", "enter_realname_hint", _realNameController, false, isRealname: true),
          Visibility(
            visible: _vm.userProfile.identityFormStatus == IdentityStatus.Reject ||
                (_vm.userProfile.identityFormStatus == IdentityStatus.WaitingVerify && (isEdit || _vm.userProfile.identityFormId == null)),
            child: _buildICNumberTextFormField(),
          ),
          Visibility(
            visible: _vm.userProfile.identityFormStatus == IdentityStatus.Reject ||
                (_vm.userProfile.identityFormStatus == IdentityStatus.WaitingVerify && (isEdit || _vm.userProfile.identityFormId == null)),
            child: _buildUploadImageButton(),
          ),
          _buildDoneButton(),
          _buildFooterText()
        ],
      );

  _buildUploadImageButton() => Container(
        padding: EdgeInsets.symmetric(horizontal: 5.auto),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 5,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 10, left: 10.auto, right: 10.auto),
                decoration: BoxDecoration(
                    //bg image
                    ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Text(
                        getTranslatedText("upload_ic_prof_hint"),
                        style: TextStyle(fontSize: 10.auto, color: CustomColor.grey),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: ColorButton(
                        title: getTranslatedText("pick_prof"),
                        width: 70.auto,
                        height: 30.auto,
                        onClick: () {
                          chooseImage();
                        },
                        isEnabled: true,
                        radius: 9.6,
                      ),
                    )
                  ],
                ),
              ),
              uploadImage == null
                  ? Container()
                  : Container(padding: EdgeInsets.all(10.auto), alignment: Alignment.centerRight, child: SizedBox(height: 80, child: Image.file(uploadImage!))),
            ],
          ),
        ),
      );

  _buildRealNameColumn() => Column(
        children: [
          _buildTextFormField("realname", "enter_realname_hint", _realNameController, false, isRealname: true),
          Visibility(
            visible: _vm.userProfile.realname == null,
            child: _buildTextFormField("ic_no", "enter_ic_no_hint", _icNoController, true),
          ),
          _buildDoneButton(),
          _buildFooterText()
        ],
      );

  _buildICNumberTextFormField() => CustomTextFormField(
        title: getTranslatedText("ic_no"),
        hintText: getTranslatedText("enter_ic_no_hint"),
        onChanged: (value) => _onTextChange(),
        onFieldSubmitted: (value) {},
        controller: _icNumberController,
        focusNode: null,
        width: context.screenWidth - 40.auto,
        textInputType: TextInputType.text,
        textInputAction: TextInputAction.next,
        enabled: isTextFieldEnabled,
      );

  _buildTextFormField(String title, String hint, TextEditingController controller, bool isLast, {bool isRealname = false}) => CustomTextFormField(
        title: getTranslatedText(title),
        hintText: getTranslatedText(hint),
        onChanged: (value) => _onTextChange(),
        onFieldSubmitted: (value) {},
        controller: controller,
        focusNode: null,
        width: context.screenWidth - 40.auto,
        textInputType: TextInputType.text,
        textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
        enabled: isTextFieldEnabled,
      );

  //hide when is _isShowIcVerificationUpload()&& wv && edit

  _buildDoneButton() => Container(
        width: context.screenWidth,
        margin: EdgeInsets.all(10.auto),
        child: ColorButton(
          title: _identityStatus == 1 ? getTranslatedText("verified") : getTranslatedText("done"),
          onClick: () {
            _onClick();
          },
          isEnabled: isButtonEnabled,
          color: CustomColor.theme_button_color,
          radius: 9.6,
        ),
      );

  _buildFooterText() {
    print(_identityStatus);
    return Visibility(
      //isEdit
      // show when _isShowIcVerificationUpload is true, status is WaitingVerify, identityformid !=null (not a new user)
      // or when _isShowIcVerificationUpload is false and changesNotAllowed is false

      //show when isEdit is false, identity status is equals to 0 and changesNotAllowed is false
      visible: !isEdit && _identityStatus == 0 && !changesNotAllowed,
      child: InkWell(
        onTap: () {
          if (_identityStatus == 0)
            // able to edit when  waiting verify
            setState(() {
              isEdit = true;
              isTextFieldEnabled = true;
            });
          else
            Navigator.of(context).pushNamed("/customer_service");
        },
        child: Container(
          height: 30.auto,
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              text: getTranslatedText("edit_ic_no_cs"),
              style: TextStyle(fontSize: 11.auto, color: CustomColor.theme_text_black_white_color),
              children: [
                TextSpan(
                  text: /*!(_vm.config?.changesNotAllowed ?? false) || */ _identityStatus == 0 ? getTranslatedText("here") : getTranslatedText("online_cs"),
                  style: TextStyle(decoration: TextDecoration.underline, color: CustomColor.theme_button_color, fontSize: 11.auto),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getState() {
    IdentityStatus status = _vm.userProfile.identityFormStatus;
    bool hasSubmitted = _vm.userProfile.identityFormId != null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        //sky8 brand check realname is null
        if (EnvironmentConfig.brandName == "SKY8") {
          if ((_vm.userProfile.realname ?? "").isNotEmpty)
            _identityStatus = 1;
          else
            _identityStatus = 4;
        } else {
          //others brand check identityFormStatus and identityFormId
          if (status == IdentityStatus.WaitingVerify && hasSubmitted) {
            //有給表單id但狀態沒驗證，不能上傳
            //waiting verify
            _identityStatus = 0;
          }
          if (status == IdentityStatus.Approve && hasSubmitted) {
            //api沒給表單id ，表示可以上傳
            //waiting submit
            _identityStatus = 1;
          }
          if (status == IdentityStatus.Reject && hasSubmitted) {
            //有給表單id但是狀態是拒絕，也可以上傳
            //rejected
            _identityStatus = 2;
          }
          if (status == IdentityStatus.WaitingVerify && !hasSubmitted) {
            //api沒給表單id ，表示可以上傳
            //waiting submit
            _identityStatus = 4;
          }
        }
        _updateUIValue();
      });
    });
  }

  _updateUIValue() {
    String _realname = _vm.userProfile.realname ?? "";

    //_isShowIcVerificationUpload
    // if (!isEdit &&
    //     (!_isShowIcVerificationUpload() && _realname != null ||
    //         _isShowIcVerificationUpload() && _vm.userProfile.identityFormStatus == IdentityStatus.Approve)) {
    //   if (_realname.isNotEmpty) {
    //     _realNameController.text = _realname;
    //     buttonText = getTranslatedText("verified");
    //     isButtonEnabled = false;
    //     isTextFieldEnabled = false;
    //   }
    // } else if (_vm.userProfile.identityFormId == null && _vm.userProfile.identityFormStatus == IdentityStatus.WaitingVerify) {
    //   //assume is a new user
    //   buttonText = getTranslatedText("done");
    //   isTextFieldEnabled = true;
    //   isEdit = false;
    // } else {
    //   if (_isShowIcVerificationUpload() && _vm.userProfile.identityFormId != null && _vm.userProfile.identityFormStatus == IdentityStatus.WaitingVerify) {
    //     _realNameController.text = _realname;
    //   }
    //   buttonText = getTranslatedText("done");
    //   isTextFieldEnabled = isEdit;
    //   isButtonEnabled = isEdit;
    // }
    isButtonEnabled = false;
    if (_identityStatus == 0) {
      //waiting verify
      buttonText = getTranslatedText("done");
      if (_realname.isNotEmpty) _realNameController.text = _realname;
      isTextFieldEnabled = false;
    } else if (_identityStatus == 1) {
      //approve
      buttonText = getTranslatedText("verified");
      if (_realname.isNotEmpty) _realNameController.text = _realname;

      isTextFieldEnabled = false;
      // } else if (_identityStatus == 2) {
      //rejected
    } else {
      //rejected
      //first time
      buttonText = getTranslatedText("done");
      isTextFieldEnabled = true;
    }
  }

  _onTextChange() {
    print("checkick");
    setState(() {
      if ((_isShowIcVerificationUpload() && _realNameController.text.isNotEmpty && _icNumberController.text.isNotEmpty && uploadImage?.path != null) ||
          ((_vm.config.icVerification ?? true) && _realNameController.text.isNotEmpty && _icNumberController.text.isNotEmpty) ||
          (!_isShowIcVerificationUpload() && !(_vm.config.icVerification ?? true) && _realNameController.text.isNotEmpty)) {
        isButtonEnabled = true;
      } else {
        isButtonEnabled = false;
      }
    });
  }

  _onClick() async {
    if (_isShowIcVerificationUpload() && !validate.validateInputLength(_icNumberController.text) && !validate.validateInputLength(_realNameController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("input_length_error"));
      });
    } else {
      ProgressDialog.show(context, _vm.brandLogoUrl);
      _vm.idVerify(
        _realNameController.text,
        _icNumberController.text,
        imageFile: uploadImage,
      );
    }
  }

  _isShowIcVerificationUpload() => (_vm.config?.icVerificationUpload ?? false);

  Future<void> chooseImage() async {
    /*File choosedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    //set source: ImageSource.camera to get image from camera
    setState(() {
      uploadImage = choosedImage;
    });*/

    ImagePicker picker = ImagePicker();
    XFile? choosedImage = await picker.pickImage(source: ImageSource.gallery);
    File imageFile;
    imageFile = File(choosedImage!.path);
    var bytes = imageFile.readAsBytesSync().lengthInBytes;
    if (bytes > 5242880) {
      //calculation = (N mb x 1024 x 1024)
      //restrict upload image to 5MB
      CustomToast.show(getTranslatedText("image_size_limit"));
    } else {
      setState(() {
        uploadImage = imageFile;
      });
      _onTextChange();
    }
  }

  _handleApiState() {
    handleApiState(_vm.idVerifyApiState, onSuccess: () {
      CustomToast.show(getTranslatedText("success"));
      isEdit = false;
      _getState();
    });
  }

  //SKY8 not allow to edit real name
  bool get changesNotAllowed => (_vm.config?.changesNotAllowed ?? false) || EnvironmentConfig.brandName == "SKY8";
}
