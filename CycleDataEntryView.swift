import SwiftUI
import CoreData
import UIKit
import PDFKit

struct CycleDataEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authViewModel: AuthViewModel
    @FetchRequest(
            entity: CycleData.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \CycleData.date, ascending: true)]
        ) var cycleData: FetchedResults<CycleData>
    
    @State private var date = Date()
    @State private var duration = ""
    @State private var symptoms = ""
    @State private var username = ""
    @State private var showingShareSheet = false
    @State private var pdfDocumentData: Data?
    @State private var reportItems = [Any]()
    @State private var showingPDF = true
    @State private var pdfData: Data?
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var showingDateRangePicker = false


    var body: some View {
        NavigationView {
            Form {
                DatePicker("Start Date", selection: $date, displayedComponents: .date)
                TextField("Duration in days", text: $duration)
                    .keyboardType(.numberPad)
                TextField("Symptoms", text: $symptoms)
                TextField("Username", text: $username)
                
                Button("Save") {
                    addCycleData()
                }
            }
            .navigationTitle("Add Cycle Data")
        }
        
        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        
                        Button("Generate Report") {
                            showingDateRangePicker = true
                        }
                        .alert("Select Date Range", isPresented: $showingDateRangePicker, actions: {
                            Button("OK") {
                                pdfDocumentData = generatePDF(from: startDate, to: endDate)
                                showingShareSheet = true
                            }
                        }, message: {
                            Text("Generate report from \(startDate.formatted(date: .long, time: .omitted)) to \(endDate.formatted(date: .long, time: .omitted))?")
                        })
                        
                        if showingPDF, let pdfData = pdfDocumentData {
                            PDFViewer(data: pdfData)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }

    }
    
    private func addCycleData() {
        let newCycleData = CycleData(context: viewContext)
        newCycleData.date = date
        newCycleData.duration = Int32(duration) ?? 0
        newCycleData.symptoms = symptoms
        newCycleData.username = username

        do {
            try viewContext.save()
            print("Cycle data saved successfully.")
        } catch {
            print("Failed to save cycle data: \(error)")
        }
    }
    
    private func generateCycleReport() {
        var report: String = "Date, Duration, Symptoms\n"
        for cycle in cycleData {
            let dateString = formatDate(cycle.date)
            let durationString = String(cycle.duration)
            let symptomsString = cycle.symptoms ?? "N/A"
            report += "\(dateString), \(durationString), \(symptomsString)\n"
        }
        reportItems = [report]
        showingShareSheet = true
    }
    
    private func generatePDF(from startDate: Date, to endDate: Date) -> Data {
        let filteredData = cycleData.filter {
            guard let date = $0.date else { return false }
            let isDateInRange = date >= startDate && date <= endDate
            let isUserMatch = $0.username == authViewModel.currentUser?.username
            return isDateInRange && isUserMatch
        }

        
        let averageDuration = filteredData.reduce(0) { $0 + Int($1.duration) } / max(filteredData.count, 1)

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { context in
            context.beginPage()
            let titleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
            let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
            let titleString = "Cycle Data Report"
            let titleRect = CGRect(x: 20, y: 20, width: pageWidth - 40, height: 40)
            titleString.draw(in: titleRect, withAttributes: titleAttributes)

            let averageDurationString = "Average Duration: \(averageDuration) days"
            let averageDurationRect = CGRect(x: 20, y: 60, width: pageWidth - 40, height: 40)
            averageDurationString.draw(in: averageDurationRect, withAttributes: titleAttributes)
            
            var yOffset = 100.0
            for cycle in filteredData {
                let dateString = formatDate(cycle.date)
                let durationString = String(cycle.duration)
                let symptomsString = cycle.symptoms ?? "N/A"
                let line = "Date: \(dateString) - Duration: \(durationString) days - Symptoms: \(symptomsString)"
                let textRect = CGRect(x: 20, y: yOffset, width: pageWidth - 40, height: 30)
                line.draw(in: textRect, withAttributes: textAttributes)
                yOffset += 20
            }
        }
        return data
    }



        private func formatDate(_ date: Date?) -> String {
            guard let date = date else { return "Unknown" }
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

struct PDFViewer: UIViewRepresentable {
    var data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
    }
}

