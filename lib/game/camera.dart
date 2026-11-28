import 'dart:math' as math;
import 'dart:ui';

/// A hand-rolled perspective camera: one divide per point, no matrices.
///
/// World axes: x to the right, y up, z along the track (metres). The camera
/// sits [behind] metres behind the hero and looks down the path.
class TrackCamera {
  /// Metres between the camera and the hero.
  static const double behind = 6.0;

  double width = 400;
  double height = 800;

  /// Focal length in pixels.
  double focal = 300;

  /// Screen y of the horizon.
  double horizon = 300;

  /// Camera height above the path (metres), chosen so the hero stands low on
  /// the screen on any aspect ratio.
  double camY = 6;

  /// World z and x the camera is at.
  double camZ = 0;
  double camX = 0;

  /// 1 normally; below 1 widens the view (used while flying).
  double zoom = 1;

  /// Screen shake offset (pixels).
  double shakeX = 0;
  double shakeY = 0;

  void resize(double w, double h) {
    width = w;
    height = h;
    focal = math.min(w, h * 0.62) * 0.78;
    horizon = h * 0.34;
    final heroGroundY = h * 0.84;
    camY = (heroGroundY - horizon) * behind / focal;
  }

  /// Follows the hero at [heroZ], drifting a little with their lane.
  void follow(double heroZ, double heroX) {
    camZ = heroZ - behind;
    camX = heroX * 0.55;
  }

  /// Pixels per metre at depth [z].
  double scaleAt(double z) {
    final dz = z - camZ;
    return dz <= 0.3 ? 0 : focal * zoom / dz;
  }

  double sx(double x, double z) => width / 2 + (x - camX) * scaleAt(z) + shakeX;
  double sy(double y, double z) => horizon + (camY - y) * scaleAt(z) + shakeY;

  bool visible(double z) => z - camZ > 0.6;

  Offset project(double x, double y, double z) => Offset(sx(x, z), sy(y, z));
}
