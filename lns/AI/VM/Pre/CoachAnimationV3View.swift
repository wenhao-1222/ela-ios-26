//
//  CoachAnimationV3View.swift
//  lns
//
//  Created by LNS2 on 2026/4/20.
//

import UIKit
import MetalKit
import simd
import Foundation

public final class CoachAnimationV3View: MTKView {

    private var globeRenderer: GlobeRenderer!
    private var displayLink: CADisplayLink?
    private var startTimestamp: CFTimeInterval?

    public init(diameter: CGFloat = 180) {
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not available on this device.")
        }

        super.init(
            frame: CGRect(x: 0, y: 0, width: diameter, height: diameter),
            device: metalDevice
        )

        configure(device: metalDevice)
    }

    public required init(coder: NSCoder) {
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not available on this device.")
        }

        super.init(coder: coder)

        self.device = metalDevice
        configure(device: metalDevice)
    }

    deinit {
        stopAnimating()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()

        if window == nil {
            stopAnimating()
        } else {
            startAnimating()
        }
    }

    public func startAnimating() {
        guard displayLink == nil else { return }

        startTimestamp = nil

        let link = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    public func stopAnimating() {
        displayLink?.invalidate()
        displayLink = nil
        startTimestamp = nil
    }

    private func configure(device: MTLDevice) {
        let renderSampleCount = device.supportsTextureSampleCount(4) ? 4 : 1

        colorPixelFormat = .bgra8Unorm
        depthStencilPixelFormat = .invalid
        sampleCount = renderSampleCount
        framebufferOnly = true
        autoResizeDrawable = true

        isPaused = true
        enableSetNeedsDisplay = false

        isOpaque = false
        layer.isOpaque = false
        backgroundColor = .clear
        clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)

        globeRenderer = GlobeRenderer(
            device: device,
            pixelFormat: colorPixelFormat,
            sampleCount: renderSampleCount,
            blobs: Self.defaultBlobs()
        )

        delegate = globeRenderer
    }

    @objc private func handleDisplayLink(_ link: CADisplayLink) {
        if startTimestamp == nil {
            startTimestamp = link.timestamp
        }

        let elapsed = link.timestamp - (startTimestamp ?? link.timestamp)

        let rotationCycle = 20.0
        let rotationProgress = elapsed.truncatingRemainder(dividingBy: rotationCycle) / rotationCycle
        globeRenderer.rotationRad = Float(rotationProgress) * Float.pi * 2

        let breathHalfCycle = 2.5
        let breathFullCycle = breathHalfCycle * 2
        let breathPhase = elapsed.truncatingRemainder(dividingBy: breathFullCycle) / breathHalfCycle
        let breathT = breathPhase <= 1 ? breathPhase : 2 - breathPhase
        let breath = CGFloat(1.0 + 0.03 * breathT)

        transform = CGAffineTransform(scaleX: breath, y: breath)

        draw()
    }

    private static func defaultBlobs() -> [GlobeBlob] {
        [
            GlobeBlob(
                latitudeDeg: 34,
                longitudeDeg: -108,
                angularRadiusDeg: 47,
                color: RGBA(argb: 0xFF7B86FF),
                alpha: 0.60,
                softnessDeg: 22,
                wobble: 0.11,
                seed: 11
            ),
            GlobeBlob(
                latitudeDeg: 26,
                longitudeDeg: -42,
                angularRadiusDeg: 43,
                color: RGBA(argb: 0xFF7EA8FF),
                alpha: 0.54,
                softnessDeg: 20,
                wobble: 0.10,
                seed: 12
            ),
            GlobeBlob(
                latitudeDeg: 31,
                longitudeDeg: 18,
                angularRadiusDeg: 28,
                color: RGBA(argb: 0xFF8CB0FF),
                alpha: 0.24,
                softnessDeg: 16,
                wobble: 0.09,
                seed: 13
            ),
            GlobeBlob(
                latitudeDeg: 42,
                longitudeDeg: 78,
                angularRadiusDeg: 36,
                color: RGBA(argb: 0xFFF0EDFF),
                alpha: 0.28,
                softnessDeg: 18,
                wobble: 0.08,
                seed: 14
            ),
            GlobeBlob(
                latitudeDeg: 48,
                longitudeDeg: 122,
                angularRadiusDeg: 26,
                color: RGBA(argb: 0xFFFFFAF4),
                alpha: 0.22,
                softnessDeg: 15,
                wobble: 0.07,
                seed: 15
            ),
            GlobeBlob(
                latitudeDeg: 30,
                longitudeDeg: 140,
                angularRadiusDeg: 20,
                color: RGBA(argb: 0xFFFFFAF4),
                alpha: 0.62,
                softnessDeg: 25,
                wobble: 0.07,
                seed: 15
            ),
            GlobeBlob(
                latitudeDeg: 42,
                longitudeDeg: 110,
                angularRadiusDeg: 27,
                color: RGBA(argb: 0xFFFFFAF4),
                alpha: 0.52,
                softnessDeg: 25,
                wobble: 0.07,
                seed: 15
            ),
            GlobeBlob(
                latitudeDeg: 50,
                longitudeDeg: 80,
                angularRadiusDeg: 20,
                color: RGBA(argb: 0xFFFFFAF4),
                alpha: 0.42,
                softnessDeg: 30,
                wobble: 0.7,
                seed: 15
            ),
            GlobeBlob(
                latitudeDeg: 60,
                longitudeDeg: 50,
                angularRadiusDeg: 20,
                color: RGBA(argb: 0xFFFFFAF4),
                alpha: 0.42,
                softnessDeg: 30,
                wobble: 0.7,
                seed: 15
            ),
            GlobeBlob(
                latitudeDeg: 3,
                longitudeDeg: 120,
                angularRadiusDeg: 12,
                color: RGBA(argb: 0xFFF2B8F2),
                alpha: 0.46,
                softnessDeg: 17,
                wobble: 0.10,
                seed: 16
            ),
            GlobeBlob(
                latitudeDeg: 5,
                longitudeDeg: 95,
                angularRadiusDeg: 15,
                color: RGBA(argb: 0xFFF2B8F2),
                alpha: 0.56,
                softnessDeg: 17,
                wobble: 0.10,
                seed: 16
            ),
            GlobeBlob(
                latitudeDeg: 7,
                longitudeDeg: 70,
                angularRadiusDeg: 16,
                color: RGBA(argb: 0xFFF2B8F2),
                alpha: 0.66,
                softnessDeg: 17,
                wobble: 0.10,
                seed: 16
            ),
            GlobeBlob(
                latitudeDeg: 9,
                longitudeDeg: 50,
                angularRadiusDeg: 15,
                color: RGBA(argb: 0xFFF2B8F2),
                alpha: 0.56,
                softnessDeg: 17,
                wobble: 0.10,
                seed: 16
            ),
            GlobeBlob(
                latitudeDeg: 11,
                longitudeDeg: 30,
                angularRadiusDeg: 12,
                color: RGBA(argb: 0xFFF2B8F2),
                alpha: 0.46,
                softnessDeg: 17,
                wobble: 0.10,
                seed: 16
            ),
            GlobeBlob(
                latitudeDeg: 11,
                longitudeDeg: 15,
                angularRadiusDeg: 10,
                color: RGBA(argb: 0xFFF2B8F2),
                alpha: 0.36,
                softnessDeg: 12,
                wobble: 0.10,
                seed: 16
            )
        ]
    }
}

private final class GlobeRenderer: NSObject, MTKViewDelegate {

    var rotationRad: Float = 0

    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue

    private let basePipeline: MTLRenderPipelineState
    private let meshPipeline: MTLRenderPipelineState
    private let screenPipeline: MTLRenderPipelineState
    private let edgePipeline: MTLRenderPipelineState

    private let surfaceCells: [SurfaceCell]

    private var meshVertices: [MeshVertex] = []
    private var meshIndices: [UInt32] = []

    private var meshVertexBuffer: MTLBuffer?
    private var meshIndexBuffer: MTLBuffer?
    private var meshVertexBufferCapacity = 0
    private var meshIndexBufferCapacity = 0

    init(
        device: MTLDevice,
        pixelFormat: MTLPixelFormat,
        sampleCount: Int,
        blobs: [GlobeBlob]
    ) {
        self.device = device

        guard let queue = device.makeCommandQueue() else {
            fatalError("Unable to create Metal command queue.")
        }

        self.commandQueue = queue
        self.surfaceCells = buildPatchMeshV3(
            blobs: blobs,
            latSegments: 52,
            lonSegments: 104
        )

        meshVertices.reserveCapacity(surfaceCells.count * 5)
        meshIndices.reserveCapacity(surfaceCells.count * 9)

        let library: MTLLibrary
        do {
            library = try device.makeLibrary(source: Self.shaderSource, options: nil)
        } catch {
            fatalError("Unable to compile Metal shaders: \(error)")
        }

        let meshVertexDescriptor = MTLVertexDescriptor()
        meshVertexDescriptor.attributes[0].format = .float4
        meshVertexDescriptor.attributes[0].offset = 0
        meshVertexDescriptor.attributes[0].bufferIndex = 0

        meshVertexDescriptor.attributes[1].format = .float4
        meshVertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.stride
        meshVertexDescriptor.attributes[1].bufferIndex = 0

        meshVertexDescriptor.layouts[0].stride = MemoryLayout<MeshVertex>.stride
        meshVertexDescriptor.layouts[0].stepFunction = .perVertex

        self.basePipeline = Self.makePipeline(
            device: device,
            library: library,
            pixelFormat: pixelFormat,
            sampleCount: sampleCount,
            vertexFunctionName: "quadVertex",
            fragmentFunctionName: "baseFragment",
            vertexDescriptor: nil,
            blend: .none
        )

        self.meshPipeline = Self.makePipeline(
            device: device,
            library: library,
            pixelFormat: pixelFormat,
            sampleCount: sampleCount,
            vertexFunctionName: "meshVertex",
            fragmentFunctionName: "meshFragment",
            vertexDescriptor: meshVertexDescriptor,
            blend: .sourceOver
        )

        self.screenPipeline = Self.makePipeline(
            device: device,
            library: library,
            pixelFormat: pixelFormat,
            sampleCount: sampleCount,
            vertexFunctionName: "quadVertex",
            fragmentFunctionName: "highlightFragment",
            vertexDescriptor: nil,
            blend: .screen
        )

        self.edgePipeline = Self.makePipeline(
            device: device,
            library: library,
            pixelFormat: pixelFormat,
            sampleCount: sampleCount,
            vertexFunctionName: "quadVertex",
            fragmentFunctionName: "edgeFragment",
            vertexDescriptor: nil,
            blend: .sourceOver
        )

        super.init()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        let drawableSize = view.drawableSize
        let width = Float(drawableSize.width)
        let height = Float(drawableSize.height)

        guard width > 1, height > 1 else { return }
        guard let drawable = view.currentDrawable else { return }
        guard let descriptor = view.currentRenderPassDescriptor else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }

        let radius = min(width, height) * 0.5
        let center = SIMD2<Float>(width * 0.5, height * 0.5)

        var uniforms = GlobeUniforms(
            viewportSize: SIMD2<Float>(width, height),
            sphereCenter: center,
            sphereRadius: radius,
            padding: 0
        )

        encoder.setRenderPipelineState(basePipeline)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<GlobeUniforms>.stride, index: 0)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<GlobeUniforms>.stride, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)

        updateMesh(
            rotationRad: rotationRad,
            sphereRadius: radius,
            sphereCenter: center
        )

        if !meshVertices.isEmpty, !meshIndices.isEmpty {
            let vertexBuffer = Self.copyArray(
                meshVertices,
                device: device,
                buffer: &meshVertexBuffer,
                capacity: &meshVertexBufferCapacity
            )

            let indexBuffer = Self.copyArray(
                meshIndices,
                device: device,
                buffer: &meshIndexBuffer,
                capacity: &meshIndexBufferCapacity
            )

            if let vertexBuffer, let indexBuffer {
                encoder.setRenderPipelineState(meshPipeline)
                encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                encoder.setVertexBytes(&uniforms, length: MemoryLayout<GlobeUniforms>.stride, index: 1)

                encoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: meshIndices.count,
                    indexType: .uint32,
                    indexBuffer: indexBuffer,
                    indexBufferOffset: 0
                )
            }
        }

        encoder.setRenderPipelineState(screenPipeline)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<GlobeUniforms>.stride, index: 0)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<GlobeUniforms>.stride, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)

        encoder.setRenderPipelineState(edgePipeline)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<GlobeUniforms>.stride, index: 0)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<GlobeUniforms>.stride, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)

        encoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private func updateMesh(
        rotationRad: Float,
        sphereRadius: Float,
        sphereCenter: SIMD2<Float>
    ) {
        meshVertices.removeAll(keepingCapacity: true)
        meshIndices.removeAll(keepingCapacity: true)

        let lightDir = Vec3d(x: -0.42, y: -0.30, z: 0.86).normalize()

        for cell in surfaceCells {
            let rotatedCorners = cell.corners.map { $0.rotateY(rotationRad) }

            let clipped = clipToFrontHemisphereWithColorsV3(
                points: rotatedCorners,
                colors: cell.cornerColors
            )

            if clipped.count < 3 {
                continue
            }

            let startIndex = UInt32(meshVertices.count)

            for clippedVertex in clipped {
                let rotatedPoint = clippedVertex.point

                let x = sphereCenter.x + sphereRadius * rotatedPoint.x
                let y = sphereCenter.y - sphereRadius * rotatedPoint.y

                let lambert = max(0, rotatedPoint.dot(lightDir))
                let front = clamp(rotatedPoint.z, 0, 1)
                let shading = clamp(0.82 + lambert * 0.24 + front * 0.10, 0.72, 1.08)

                let color = clippedVertex.color.shadedV3(shading)

                meshVertices.append(
                    MeshVertex(
                        position: SIMD4<Float>(x, y, 0, 1),
                        color: color.simd
                    )
                )
            }

            for vertexIndex in 1..<(clipped.count - 1) {
                meshIndices.append(startIndex)
                meshIndices.append(startIndex + UInt32(vertexIndex))
                meshIndices.append(startIndex + UInt32(vertexIndex + 1))
            }
        }
    }

    private enum BlendModeKind {
        case none
        case sourceOver
        case screen
    }

    private static func makePipeline(
        device: MTLDevice,
        library: MTLLibrary,
        pixelFormat: MTLPixelFormat,
        sampleCount: Int,
        vertexFunctionName: String,
        fragmentFunctionName: String,
        vertexDescriptor: MTLVertexDescriptor?,
        blend: BlendModeKind
    ) -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: vertexFunctionName)
        descriptor.fragmentFunction = library.makeFunction(name: fragmentFunctionName)
        descriptor.vertexDescriptor = vertexDescriptor
        descriptor.rasterSampleCount = sampleCount
        descriptor.colorAttachments[0].pixelFormat = pixelFormat

        let attachment = descriptor.colorAttachments[0]!

        switch blend {
        case .none:
            attachment.isBlendingEnabled = false

        case .sourceOver:
            attachment.isBlendingEnabled = true
            attachment.rgbBlendOperation = .add
            attachment.alphaBlendOperation = .add
            attachment.sourceRGBBlendFactor = .one
            attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
            attachment.sourceAlphaBlendFactor = .one
            attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha

        case .screen:
            attachment.isBlendingEnabled = true
            attachment.rgbBlendOperation = .add
            attachment.alphaBlendOperation = .add
            attachment.sourceRGBBlendFactor = .one
            attachment.destinationRGBBlendFactor = .oneMinusSourceColor
            attachment.sourceAlphaBlendFactor = .one
            attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        }

        do {
            return try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError("Unable to create Metal pipeline: \(error)")
        }
    }

    private static func copyArray<T>(
        _ array: [T],
        device: MTLDevice,
        buffer: inout MTLBuffer?,
        capacity: inout Int
    ) -> MTLBuffer? {
        let length = array.count * MemoryLayout<T>.stride

        if length == 0 {
            return nil
        }

        if buffer == nil || capacity < length {
            capacity = max(max(length, capacity * 2), 4096)
            buffer = device.makeBuffer(length: capacity, options: [.storageModeShared])
        }

        guard let target = buffer else {
            return nil
        }

        array.withUnsafeBytes { rawBuffer in
            if let baseAddress = rawBuffer.baseAddress {
                memcpy(target.contents(), baseAddress, length)
            }
        }

        return target
    }

    private static let shaderSource = """
    #include <metal_stdlib>
    using namespace metal;

    struct GlobeUniforms {
        float2 viewportSize;
        float2 sphereCenter;
        float sphereRadius;
        float padding;
    };

    struct QuadOut {
        float4 position [[position]];
    };

    struct MeshVertexIn {
        float4 position [[attribute(0)]];
        float4 color [[attribute(1)]];
    };

    struct MeshOut {
        float4 position [[position]];
        float4 color;
    };

    float2 pixelToClip(float2 p, float2 size) {
        return float2(
            p.x / size.x * 2.0 - 1.0,
            1.0 - p.y / size.y * 2.0
        );
    }

    float4 radial3(
        float2 p,
        float2 center,
        float radius,
        float4 c0,
        float4 c1,
        float4 c2
    ) {
        float safeRadius = max(radius, 0.0001);
        float t = clamp(distance(p, center) / safeRadius, 0.0, 1.0);

        if (t < 0.5) {
            return mix(c0, c1, t / 0.5);
        }

        return mix(c1, c2, (t - 0.5) / 0.5);
    }

    float4 radial4(
        float2 p,
        float2 center,
        float radius,
        float4 c0,
        float4 c1,
        float4 c2,
        float4 c3
    ) {
        float safeRadius = max(radius, 0.0001);
        float t = clamp(distance(p, center) / safeRadius, 0.0, 1.0);

        if (t < 0.33333334) {
            return mix(c0, c1, t * 3.0);
        }

        if (t < 0.6666667) {
            return mix(c1, c2, (t - 0.33333334) * 3.0);
        }

        return mix(c2, c3, (t - 0.6666667) * 3.0);
    }

    float sphereCoverageAlpha(
        float2 p,
        constant GlobeUniforms &u
    ) {
        float edgeDistance = u.sphereRadius - distance(p, u.sphereCenter);
        float feather = max(fwidth(edgeDistance) * 1.5, 1.0);
        return smoothstep(-feather, feather, edgeDistance);
    }

    vertex QuadOut quadVertex(
        uint vertexID [[vertex_id]],
        constant GlobeUniforms &u [[buffer(0)]]
    ) {
        float2 p;

        switch (vertexID) {
            case 0:
                p = float2(0.0, 0.0);
                break;
            case 1:
                p = float2(u.viewportSize.x, 0.0);
                break;
            case 2:
                p = float2(0.0, u.viewportSize.y);
                break;
            case 3:
                p = float2(u.viewportSize.x, 0.0);
                break;
            case 4:
                p = float2(u.viewportSize.x, u.viewportSize.y);
                break;
            default:
                p = float2(0.0, u.viewportSize.y);
                break;
        }

        QuadOut out;
        out.position = float4(pixelToClip(p, u.viewportSize), 0.0, 1.0);
        return out;
    }

    fragment float4 baseFragment(
        QuadOut in [[stage_in]],
        constant GlobeUniforms &u [[buffer(0)]]
    ) {
        float2 p = in.position.xy;
        float coverage = sphereCoverageAlpha(p, u);

        if (coverage <= 0.0001) {
            discard_fragment();
            return float4(0.0);
        }

        float r = u.sphereRadius;

        float4 baseColor = radial4(
            p,
            u.sphereCenter + float2(-r * 0.24, -r * 0.30),
            r * 1.30,
            float4(251.0 / 255.0, 252.0 / 255.0, 255.0 / 255.0, 1.0),
            float4(237.0 / 255.0, 241.0 / 255.0, 255.0 / 255.0, 1.0),
            float4(220.0 / 255.0, 228.0 / 255.0, 248.0 / 255.0, 1.0),
            float4(188.0 / 255.0, 200.0 / 255.0, 224.0 / 255.0, 1.0)
        );

        float4 dark = radial3(
            p,
            u.sphereCenter + float2(r * 0.45, r * 0.48),
            r * 1.10,
            float4(0.0, 0.0, 0.0, 0.0),
            float4(11.0 / 255.0, 27.0 / 255.0, 74.0 / 255.0, 20.0 / 255.0),
            float4(4.0 / 255.0, 11.0 / 255.0, 26.0 / 255.0, 50.0 / 255.0)
        );

        float3 rgb = baseColor.rgb;
        rgb = mix(rgb, rgb * dark.rgb, dark.a);

        return float4(rgb * coverage, coverage);
    }

    vertex MeshOut meshVertex(
        MeshVertexIn in [[stage_in]],
        constant GlobeUniforms &u [[buffer(1)]]
    ) {
        MeshOut out;
        out.position = float4(pixelToClip(in.position.xy, u.viewportSize), 0.0, 1.0);
        out.color = in.color;
        return out;
    }

    fragment float4 meshFragment(MeshOut in [[stage_in]]) {
        return float4(in.color.rgb * in.color.a, in.color.a);
    }

    fragment float4 highlightFragment(
        QuadOut in [[stage_in]],
        constant GlobeUniforms &u [[buffer(0)]]
    ) {
        float2 p = in.position.xy;
        float coverage = sphereCoverageAlpha(p, u);

        if (coverage <= 0.0001) {
            discard_fragment();
            return float4(0.0);
        }

        float r = u.sphereRadius;

        float4 source = radial3(
            p,
            u.sphereCenter + float2(-r * 0.18, -r * 0.44),
            r * 0.92,
            float4(1.0, 1.0, 1.0, 0.32),
            float4(1.0, 1.0, 1.0, 0.08),
            float4(1.0, 1.0, 1.0, 0.0)
        );

        float a = source.a * coverage;

        return float4(a, a, a, a);
    }

    fragment float4 edgeFragment(
        QuadOut in [[stage_in]],
        constant GlobeUniforms &u [[buffer(0)]]
    ) {
        float2 p = in.position.xy;
        float coverage = sphereCoverageAlpha(p, u);

        if (coverage <= 0.0001) {
            discard_fragment();
            return float4(0.0);
        }

        float a = radial3(
            p,
            u.sphereCenter,
            u.sphereRadius,
            float4(0.0, 0.0, 0.0, 0.0),
            float4(0.0, 0.0, 0.0, 0.0),
            float4(0.0, 0.0, 0.0, 0.10)
        ).a * coverage;

        return float4(0.0, 0.0, 0.0, a);
    }
    """
}

private struct GlobeUniforms {
    var viewportSize: SIMD2<Float>
    var sphereCenter: SIMD2<Float>
    var sphereRadius: Float
    var padding: Float
}

private struct MeshVertex {
    var position: SIMD4<Float>
    var color: SIMD4<Float>
}

private struct GlobeBlob {
    let latitudeDeg: Float
    let longitudeDeg: Float
    let angularRadiusDeg: Float
    let color: RGBA
    let alpha: Float
    let softnessDeg: Float
    let wobble: Float
    let seed: Float
}

private struct SurfaceCell {
    let corners: [Vec3d]
    let center: Vec3d
    let centerColor: RGBA
    let cornerColors: [RGBA]
}

private struct ClippedVertexV3 {
    let point: Vec3d
    let color: RGBA
}

private struct Vec3d {
    let x: Float
    let y: Float
    let z: Float

    func rotateY(_ angleRad: Float) -> Vec3d {
        let c = cosf(angleRad)
        let s = sinf(angleRad)

        return Vec3d(
            x: x * c + z * s,
            y: y,
            z: z * c - x * s
        )
    }

    func dot(_ other: Vec3d) -> Float {
        x * other.x + y * other.y + z * other.z
    }

    func normalize() -> Vec3d {
        let length = sqrtf(x * x + y * y + z * z)

        if length <= 1e-6 {
            return self
        }

        return Vec3d(
            x: x / length,
            y: y / length,
            z: z / length
        )
    }
}

private struct RGBA {
    var r: Float
    var g: Float
    var b: Float
    var a: Float

    static let clear = RGBA(r: 0, g: 0, b: 0, a: 0)

    init(r: Float, g: Float, b: Float, a: Float) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    init(argb: UInt32) {
        self.a = Float((argb >> 24) & 0xFF) / 255
        self.r = Float((argb >> 16) & 0xFF) / 255
        self.g = Float((argb >> 8) & 0xFF) / 255
        self.b = Float(argb & 0xFF) / 255
    }

    var simd: SIMD4<Float> {
        SIMD4<Float>(r, g, b, a)
    }

    func shadedV3(_ factor: Float) -> RGBA {
        RGBA(
            r: clamp(r * factor, 0, 1),
            g: clamp(g * factor, 0, 1),
            b: clamp(b * factor, 0, 1),
            a: a
        )
    }
}

private func buildPatchMeshV3(
    blobs: [GlobeBlob],
    latSegments: Int,
    lonSegments: Int
) -> [SurfaceCell] {
    var cells: [SurfaceCell] = []
    cells.reserveCapacity(latSegments * lonSegments / 2)

    let latStart: Float = -90
    let latEnd: Float = 90
    let lonStart: Float = -180
    let lonEnd: Float = 180

    for latIndex in 0..<latSegments {
        let lat0 = lerpFloatV3(latStart, latEnd, Float(latIndex) / Float(latSegments))
        let lat1 = lerpFloatV3(latStart, latEnd, Float(latIndex + 1) / Float(latSegments))
        let latCenter = (lat0 + lat1) * 0.5

        for lonIndex in 0..<lonSegments {
            let lon0 = lerpFloatV3(lonStart, lonEnd, Float(lonIndex) / Float(lonSegments))
            let lon1 = lerpFloatV3(lonStart, lonEnd, Float(lonIndex + 1) / Float(lonSegments))
            let lonCenter = (lon0 + lon1) * 0.5

            let center = unitSpherePointV3(latitudeDeg: latCenter, longitudeDeg: lonCenter)

            let color = compositeBlobColorV3(
                blobs: blobs,
                point: center,
                latitudeDeg: latCenter,
                longitudeDeg: lonCenter
            )

            if color.a <= 0.01 {
                continue
            }

            let p00 = unitSpherePointV3(latitudeDeg: lat0, longitudeDeg: lon0)
            let p10 = unitSpherePointV3(latitudeDeg: lat1, longitudeDeg: lon0)
            let p11 = unitSpherePointV3(latitudeDeg: lat1, longitudeDeg: lon1)
            let p01 = unitSpherePointV3(latitudeDeg: lat0, longitudeDeg: lon1)

            cells.append(
                SurfaceCell(
                    corners: [p00, p10, p11, p01],
                    center: center,
                    centerColor: color,
                    cornerColors: [
                        compositeBlobColorV3(blobs: blobs, point: p00, latitudeDeg: lat0, longitudeDeg: lon0),
                        compositeBlobColorV3(blobs: blobs, point: p10, latitudeDeg: lat1, longitudeDeg: lon0),
                        compositeBlobColorV3(blobs: blobs, point: p11, latitudeDeg: lat1, longitudeDeg: lon1),
                        compositeBlobColorV3(blobs: blobs, point: p01, latitudeDeg: lat0, longitudeDeg: lon1)
                    ]
                )
            )
        }
    }

    return cells
}

private func compositeBlobColorV3(
    blobs: [GlobeBlob],
    point: Vec3d,
    latitudeDeg: Float,
    longitudeDeg: Float
) -> RGBA {
    var outA: Float = 0
    var premulR: Float = 0
    var premulG: Float = 0
    var premulB: Float = 0

    for blob in blobs {
        let alpha = coverageV3(
            blob: blob,
            point: point,
            sampleLatitudeDeg: latitudeDeg,
            sampleLongitudeDeg: longitudeDeg
        )

        if alpha <= 0.001 {
            continue
        }

        premulR = blob.color.r * alpha + premulR * (1 - alpha)
        premulG = blob.color.g * alpha + premulG * (1 - alpha)
        premulB = blob.color.b * alpha + premulB * (1 - alpha)
        outA = alpha + outA * (1 - alpha)
    }

    if outA <= 0.001 {
        return .clear
    }

    return RGBA(
        r: clamp(premulR / outA, 0, 1),
        g: clamp(premulG / outA, 0, 1),
        b: clamp(premulB / outA, 0, 1),
        a: clamp(outA, 0, 1)
    )
}

private func coverageV3(
    blob: GlobeBlob,
    point: Vec3d,
    sampleLatitudeDeg: Float,
    sampleLongitudeDeg: Float
) -> Float {
    let blobCenter = unitSpherePointV3(
        latitudeDeg: blob.latitudeDeg,
        longitudeDeg: blob.longitudeDeg
    )

    let angle = acosf(clamp(point.dot(blobCenter), -1, 1))

    let radiusScale = clamp(
        1 + blob.wobble * organicNoiseV3(point: point, seed: blob.seed),
        0.72,
        1.28
    )

    let effectiveRadius = degreesToRadians(blob.angularRadiusDeg * radiusScale)
    let softness = degreesToRadians(blob.softnessDeg)

    return smoothStepV3(
        edge0: effectiveRadius + softness,
        edge1: effectiveRadius - softness,
        value: angle
    ) * blob.alpha
}

private func organicNoiseV3(point: Vec3d, seed: Float) -> Float {
    let a = sinf(point.x * 6.3 + point.y * 2.1 + seed * 0.91)
    let b = cosf(point.y * 5.4 - point.z * 3.7 - seed * 1.37)
    let c = sinf((point.x - point.z * 1.2 + point.y * 0.8) * 4.6 + seed * 1.83)

    return 0.55 * a * b + 0.45 * c
}

private func unitSpherePointV3(
    latitudeDeg: Float,
    longitudeDeg: Float
) -> Vec3d {
    let lat = degreesToRadians(latitudeDeg)
    let lon = degreesToRadians(longitudeDeg)
    let cosLat = cosf(lat)

    return Vec3d(
        x: cosLat * sinf(lon),
        y: sinf(lat),
        z: cosLat * cosf(lon)
    )
}

private func clipToFrontHemisphereWithColorsV3(
    points: [Vec3d],
    colors: [RGBA]
) -> [ClippedVertexV3] {
    if points.isEmpty || points.count != colors.count {
        return []
    }

    var clipped: [ClippedVertexV3] = []
    clipped.reserveCapacity(points.count + 1)

    var previousPoint = points[points.count - 1]
    var previousColor = colors[colors.count - 1]
    var previousInside = previousPoint.z >= 0

    for index in points.indices {
        let currentPoint = points[index]
        let currentColor = colors[index]
        let currentInside = currentPoint.z >= 0

        if previousInside && currentInside {
            clipped.append(
                ClippedVertexV3(
                    point: currentPoint,
                    color: currentColor
                )
            )
        } else if previousInside && !currentInside {
            clipped.append(
                intersectAtHorizonWithColorV3(
                    aPoint: previousPoint,
                    aColor: previousColor,
                    bPoint: currentPoint,
                    bColor: currentColor
                )
            )
        } else if !previousInside && currentInside {
            clipped.append(
                intersectAtHorizonWithColorV3(
                    aPoint: previousPoint,
                    aColor: previousColor,
                    bPoint: currentPoint,
                    bColor: currentColor
                )
            )

            clipped.append(
                ClippedVertexV3(
                    point: currentPoint,
                    color: currentColor
                )
            )
        }

        previousPoint = currentPoint
        previousColor = currentColor
        previousInside = currentInside
    }

    return clipped
}

private func intersectAtHorizonWithColorV3(
    aPoint: Vec3d,
    aColor: RGBA,
    bPoint: Vec3d,
    bColor: RGBA
) -> ClippedVertexV3 {
    let denominator = bPoint.z - aPoint.z

    if abs(denominator) < 1e-6 {
        return ClippedVertexV3(
            point: Vec3d(x: aPoint.x, y: aPoint.y, z: 0).normalize(),
            color: aColor
        )
    }

    let t = clamp((0 - aPoint.z) / denominator, 0, 1)

    return ClippedVertexV3(
        point: Vec3d(
            x: aPoint.x + (bPoint.x - aPoint.x) * t,
            y: aPoint.y + (bPoint.y - aPoint.y) * t,
            z: 0
        ).normalize(),
        color: lerpColorV3(aColor, bColor, t)
    )
}

private func lerpColorV3(
    _ start: RGBA,
    _ end: RGBA,
    _ fraction: Float
) -> RGBA {
    let t = clamp(fraction, 0, 1)

    return RGBA(
        r: lerpFloatV3(start.r, end.r, t),
        g: lerpFloatV3(start.g, end.g, t),
        b: lerpFloatV3(start.b, end.b, t),
        a: lerpFloatV3(start.a, end.a, t)
    )
}

private func smoothStepV3(
    edge0: Float,
    edge1: Float,
    value: Float
) -> Float {
    if edge0 == edge1 {
        return value < edge0 ? 0 : 1
    }

    let t = clamp((value - edge0) / (edge1 - edge0), 0, 1)
    return t * t * (3 - 2 * t)
}

private func lerpFloatV3(
    _ start: Float,
    _ end: Float,
    _ fraction: Float
) -> Float {
    start + (end - start) * fraction
}

private func degreesToRadians(_ degrees: Float) -> Float {
    degrees * Float.pi / 180
}

private func clamp(_ value: Float, _ lower: Float, _ upper: Float) -> Float {
    min(max(value, lower), upper)
}
