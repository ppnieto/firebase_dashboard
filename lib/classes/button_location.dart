
enum ButtonLocation { Floating, ActionBar, Bottom }

enum ButtonAction { Short, Large }

extension _BL on String {
  ButtonLocation toButtonLocation() {
    // default
    // if (this == _ButtonLocation.Floating.toString()) return _ButtonLocation.Floating;
    if (this == ButtonLocation.ActionBar.toString())
      return ButtonLocation.ActionBar;
    if (this == ButtonLocation.Bottom.toString()) return ButtonLocation.Bottom;
    return ButtonLocation.Floating;
  }
}

extension _BA on String {
  ButtonAction toButtonAction() {
    if (this == ButtonAction.Large.toString()) return ButtonAction.Short;
    return ButtonAction.Short;
  }
}
