// ANSY: many trails drawn as one native layer, below every marker (iOS, Apple
// Maps: ios/AirMaps/AIRMapTrails.h). Fed by commands, never by re-rendering:
//  - setTrails: every trail's recorded line, every few seconds;
//  - setTips: the stretch from each line's end to its aircraft, every frame.
import * as React from 'react';
import {
  codegenNativeCommands,
  requireNativeComponent,
  type HostComponent,
  type ViewProps,
} from 'react-native';
import type {LatLng} from './sharedTypes';

export type MapTrailsProps = ViewProps & {
  /** line width, in points; default 1.5 */
  strokeWidth?: number;
};

export type MapTrail = {
  id: string;
  coordinates: LatLng[];
  /** one per coordinate (the colour of the segment ending there), or one for all */
  colors: string[];
};

export type MapTrailTip = {id: string; color: string; coordinates: LatLng[]};

type NativeProps = MapTrailsProps;

interface NativeCommands {
  setTrails: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    trails: string,
  ) => void;
  setTips: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    tips: string,
  ) => void;
}

const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['setTrails', 'setTips'],
});

let NativeTrails: HostComponent<NativeProps> | undefined;

export class MapTrails extends React.Component<MapTrailsProps> {
  private ref = React.createRef<React.ElementRef<HostComponent<NativeProps>>>();

  setTrails(trails: MapTrail[]) {
    if (!this.ref.current) return;
    Commands.setTrails(
      this.ref.current,
      JSON.stringify(
        trails.map(trail => ({
          id: trail.id,
          p: trail.coordinates.flatMap(c => [c.latitude, c.longitude]),
          c: trail.colors,
        })),
      ),
    );
  }

  setTips(tips: MapTrailTip[]) {
    if (!this.ref.current) return;
    Commands.setTips(
      this.ref.current,
      tips
        .map(
          tip =>
            `${tip.id}|${tip.color}|${tip.coordinates
              .map(c => `${c.latitude},${c.longitude}`)
              .join(',')}`,
        )
        .join(';'),
    );
  }

  render() {
    if (!NativeTrails) {
      NativeTrails = requireNativeComponent<NativeProps>('AIRMapTrails');
    }
    return <NativeTrails {...this.props} ref={this.ref} />;
  }
}

export default MapTrails;
