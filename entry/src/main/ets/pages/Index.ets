import { sensor } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';

@Entry
@Component
export struct Index {
  @State heartRate: number = 0;

  aboutToAppear() {
    this.requestHealthPermission(); // get permission when app open
  }

  build() {
    Column() {
      Stack() {
        Text()
          .width(300)
          .height(300)
          .backgroundColor($r('app.color.black'))
        Particle({
          particles: [
            {
              emitter: {
                particle: {
                  type: ParticleType.POINT,
                  config: {
                    radius: 5
                  },
                  count: 255,
                },
              },
              color: {
                range: [Color.White, Color.Red], // Initial color range.
              },
            },
          ]
        }).width(200).height(200)
      }.width('10%').height('10%').align(Alignment.Top)

      Image($r('app.media.heartrate')).width(50).height(50).margin({ bottom: 10 })
      Text('Heart Rate: ' + this.heartRate + ' bpm')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  // get permissions
  async requestHealthPermission() {
    const context = getContext(this);
    const atManager = abilityAccessCtrl.createAtManager();
    const permissions: Permissions[] = [
      'ohos.permission.READ_HEALTH_DATA',
    ];

    try {
      const result = await atManager.requestPermissionsFromUser(context, permissions);
      if (result.authResults.every(r => r === 0)) {
        console.info('All permissions granted');
        this.subscribeHeartRateSensor();
      } else {
        console.error('One or more permission rejected.');
      }
    } catch (err) {
      console.error('Failed to get permission: ' + JSON.stringify(err));
    }
  }

  // get heart rate sensor
  subscribeHeartRateSensor() {
    sensor.getSensorList((error: BusinessError, data: Array<sensor.Sensor>) => {
      if (error) {
        return;
      }

      const heartRateSensor = data.find(s => s.sensorName.toLowerCase().includes('heart'));
      if (!heartRateSensor) {
        return;
      }
      // Continuous data retrieval
      sensor.on(sensor.SensorId.HEART_RATE, (data: sensor.HeartRateResponse) => {
        if (data && data.heartRate !== undefined) {
          this.heartRate = data.heartRate;
          console.info($r('app.string.hr') + ' ' + data.heartRate);
        }
      }, { interval: 100000000 }); // 100ms (nano)
    });
  }
}
