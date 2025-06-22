//
//  CameraClientTests.swift
//  PochiTests
//
//  Created by Pochi Team on 2025/06/22.
//

import Testing
import Dependencies
@testable import Pochi

struct CameraClientTests {
    
    @Test func testCameraPermissionRequest() async throws {
        let permissionGranted = await withDependencies {
            $0.camera = .testValue
        } operation: {
            @Dependency(\.camera) var camera
            return await camera.requestPermission()
        }
        
        #expect(permissionGranted == false)
    }
    
    @Test func testCameraPermissionRequestGranted() async throws {
        let permissionGranted = await withDependencies {
            $0.camera = CameraClient(
                requestPermission: { true },
                startScanning: { AsyncStream<String> { _ in } },
                stopScanning: { }
            )
        } operation: {
            @Dependency(\.camera) var camera
            return await camera.requestPermission()
        }
        
        #expect(permissionGranted == true)
    }
    
    @Test func testStartScanning() async throws {
        let testBarcode = "1234567890123"
        
        await withDependencies {
            $0.camera = CameraClient(
                requestPermission: { true },
                startScanning: {
                    AsyncStream<String> { continuation in
                        continuation.yield(testBarcode)
                        continuation.finish()
                    }
                },
                stopScanning: { }
            )
        } operation: {
            @Dependency(\.camera) var camera
            let stream = camera.startScanning()
            
            var receivedBarcode: String?
            for await barcode in stream {
                receivedBarcode = barcode
                break
            }
            
            #expect(receivedBarcode == testBarcode)
        }
    }
    
    @Test func testStopScanning() async throws {
        var stopScanningCalled = false
        
        await withDependencies {
            $0.camera = CameraClient(
                requestPermission: { true },
                startScanning: { AsyncStream<String> { _ in } },
                stopScanning: {
                    stopScanningCalled = true
                }
            )
        } operation: {
            @Dependency(\.camera) var camera
            await camera.stopScanning()
        }
        
        #expect(stopScanningCalled == true)
    }
    
    @Test func testScanningMultipleBarcodes() async throws {
        let testBarcodes = ["1234567890123", "9876543210987", "5555555555555"]
        
        await withDependencies {
            $0.camera = CameraClient(
                requestPermission: { true },
                startScanning: {
                    AsyncStream<String> { continuation in
                        for barcode in testBarcodes {
                            continuation.yield(barcode)
                        }
                        continuation.finish()
                    }
                },
                stopScanning: { }
            )
        } operation: {
            @Dependency(\.camera) var camera
            let stream = camera.startScanning()
            
            var receivedBarcodes: [String] = []
            for await barcode in stream {
                receivedBarcodes.append(barcode)
            }
            
            #expect(receivedBarcodes == testBarcodes)
        }
    }
}