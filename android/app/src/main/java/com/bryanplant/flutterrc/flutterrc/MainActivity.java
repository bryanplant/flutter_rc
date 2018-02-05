package com.bryanplant.flutterrc.flutterrc;

import android.Manifest;
import android.annotation.TargetApi;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.content.Intent;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@TargetApi(23)
public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.bryanplant/bluetooth";
    int REQUEST_ENABLE_BT = 0;
    private final String UUID_STRING = "00001101-0000-1000-8000-00805F9B34FB";
    UUID myUUID = UUID.fromString(UUID_STRING);

    BluetoothThread bluetoothThread;
    ConnectedThread connectedThread;
    BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    Set<BluetoothDevice> pairedDevices = mBluetoothAdapter.getBondedDevices();
    List<String> pairedNames = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall call, Result result) {
                switch (call.method) {
                    case "init":

                        if (!mBluetoothAdapter.isEnabled()) {
                            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
                        }

                        if (pairedDevices.size() > 0) {
                            // There are paired devices. Get the name and address of each paired device.
                            for (BluetoothDevice device : pairedDevices) {
                                String deviceName = device.getName();
                                pairedNames.add(deviceName);
                                //String deviceHardwareAddress = device.getAddress(); // MAC address
                            }
                        }

                        result.success(pairedNames);
                        break;
                    case "connect":
                        for (BluetoothDevice b : pairedDevices) {
                            if (b.getName().equals(call.arguments)) {
                                String address = b.getAddress();
                                bluetoothThread = new BluetoothThread(address);
                                bluetoothThread.start();
                            }
                        }
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if(bluetoothThread != null){
            bluetoothThread.cancel();
        }
    }

    private void startBluetoothThread(BluetoothSocket socket) {
        connectedThread = new ConnectedThread(socket);
        connectedThread.start();
    }

    class BluetoothThread extends Thread {
        private BluetoothSocket bluetoothSocket = null;
        private BluetoothDevice bluetoothDevice;

        BluetoothThread(String s) {
            BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
            bluetoothDevice = adapter.getRemoteDevice(s);

            try {
                bluetoothSocket = bluetoothDevice.createRfcommSocketToServiceRecord(myUUID);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void run() {
            boolean success = false;
            try {
                bluetoothSocket.connect();
                success = true;
            } catch (IOException e) {
                e.printStackTrace();

                final String eMessage = e.getMessage();
                runOnUiThread(new Runnable() {
                    @Override
                    public void run()  {
                        System.out.println("something went wrong: \n" + eMessage);
                    }
                });

                try {
                    bluetoothSocket.close();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            }
            if(success){
                System.out.println("Connected!");
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {

                    }
                });
                startBluetoothThread(bluetoothSocket);
            }
        }

        void cancel() {
            try {
                bluetoothSocket.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /*
    ThreadConnected:
    Background Thread to handle Bluetooth data communication
    after connected
     */
    private class ConnectedThread extends Thread {
        private final BluetoothSocket connectedBluetoothSocket;
        private final InputStream connectedInputStream;
        private final OutputStream connectedOutputStream;

        ConnectedThread(BluetoothSocket socket) {
            connectedBluetoothSocket = socket;
            InputStream in = null;
            OutputStream out = null;

            try {
                in = socket.getInputStream();
                out = socket.getOutputStream();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

            connectedInputStream = in;
            connectedOutputStream = out;
        }

        @Override
        public void run() {
            byte[] buffer = new byte[1024];
            int bytes;

            while (true) {
                try {
                    bytes = connectedInputStream.read(buffer);
                    String strReceived = new String(buffer, 0, bytes);
                    final String msgReceived = String.valueOf(bytes) +
                            " bytes received:\n"
                            + strReceived;

                    runOnUiThread(new Runnable(){

                        @Override
                        public void run() {

                        }});

                } catch (IOException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();

                    final String msgConnectionLost = "Connection lost:\n"
                            + e.getMessage();
                    runOnUiThread(new Runnable(){

                        @Override
                        public void run() {

                        }});
                }
            }
        }

        public void write(byte[] buffer) {
            try {
                connectedOutputStream.write(buffer);
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }

        public void cancel() {
            try {
                connectedBluetoothSocket.close();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    }
}
