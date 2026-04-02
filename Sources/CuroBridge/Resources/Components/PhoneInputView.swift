//
//  PhoneNumberInput.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 25/03/26.
//

import SwiftUI
import PhoneNumberKit

public struct Country: Identifiable, Codable, Equatable {
    public var id: String { code }
    public let name: String
    public let dialCode: String
    public let code: String
    
    public enum CodingKeys: String, CodingKey {
        case name, dialCode, code
    }
    
    public var flag: String {
        code
            .unicodeScalars
            .compactMap { UnicodeScalar(127397 + $0.value) }
            .map(String.init)
            .joined()
    }
}

@MainActor
public class CountryProvider {
    public static let shared = CountryProvider()
    private let phoneNumberKit = PhoneNumberUtility()
    private let basePriorityCountries: [String] = ["US", "IN"]
    private var systemCountryCode: String {
        Locale.current.region?.identifier ?? "US"
    }
    
    private var priorityCountries: [String] {
        ([systemCountryCode] + basePriorityCountries)
            .reduce(into: []) { result, code in
                if !result.contains(code) {
                    result.append(code)
                }
            }
    }
    
    func getAllCountries() -> [Country] {
        let countries = phoneNumberKit.allCountries()
            .filter { $0 != "001" }
            .compactMap { code -> Country? in
                guard let dial = phoneNumberKit.countryCode(for: code) else { return nil }
                let name = Locale.current.localizedString(forRegionCode: code) ?? code
                
                return Country(
                    name: name,
                    dialCode: "+\(dial)",
                    code: code
                )
            }
        
        return countries.sorted { lhs, rhs in
            let lhsPriority = priorityCountries.firstIndex(of: lhs.code)
            let rhsPriority = priorityCountries.firstIndex(of: rhs.code)
            
            switch (lhsPriority, rhsPriority) {
            case let (l?, r?):
                return l < r // both are priority → keep defined order
            case (_?, nil):
                return true  // lhs is priority → comes first
            case (nil, _?):
                return false // rhs is priority → comes first
            default:
                return lhs.name < rhs.name // neither → sort alphabetically
            }
        }
    }
    
    public func getFirstCountry() -> Country {
        let provider = CountryProvider.shared
        let countries = provider.getAllCountries()
        let systemCode = Locale.current.region?.identifier ?? "US"
        
        return countries.first(where: { $0.code == systemCode }) ?? countries.first!
    }
}

public struct PhoneInputView: View {
    @Binding public var phoneNumber: String
    @Binding var selectedCountry: Country
    @Binding var errorDesc: String?
    
    @State var placeholder: String = "Phone number"
    @State private var countries: [Country] = CountryProvider.shared.getAllCountries()
    @State private var showPicker = false
    @State private var isValid = true
    
    private let phoneNumberKit = PhoneNumberUtility()
    
    public init(phoneNumber: Binding<String>, selectedCountry: Binding<Country>, errorDesc: Binding<String?>) {
        self._phoneNumber = phoneNumber
        self._selectedCountry = selectedCountry
        self._errorDesc = errorDesc
    }
    
    public func formatNumber(_ newValue: String) {
        let formatter = PartialFormatter()
        formatter.defaultRegion = selectedCountry.code
        let raw = newValue.filter { $0.isNumber }
        let formatted = formatter.formatPartial(raw)

        if formatted != newValue {
            phoneNumber = formatted
        }
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button {
                showPicker = true
            } label: {
                HStack {
                    Text(selectedCountry.flag)
                    
                    Text(selectedCountry.dialCode)
                        .font(.custom(AppFont.semibold.rawValue, size: 14))
                        .foregroundStyle(ThemeColor.text.color)
                }
                .padding(.all, 16)
                .background(
                    ThemeColor.inputBackground.color
                        .clipShape(
                            RoundedRectangle(cornerRadius: 20)
                        )
                )
            }
            .buttonStyle(PressableButtonStyle())
            
            
            VStack(alignment: .leading) {
                HStack {
                    TextField(placeholder, text: $phoneNumber)
                        .font(.custom(AppFont.semibold.rawValue, size: 14))
                        .foregroundStyle(ThemeColor.text.color)
                        .textContentType(.none)
                        .keyboardType(.phonePad)
                        .autocorrectionDisabled(true)
                        .submitLabel(.done)
                        .onChange(of: phoneNumber) { _, newValue in
                            formatNumber(newValue)

                            validate()
                        }
                }
                .padding(.all, 16)
                .background(
                    ThemeColor.inputBackground.color
                        .clipShape(
                            RoundedRectangle(cornerRadius: 20)
                        )
                )
                
                if !isValid || errorDesc != nil {
                    Text(errorDesc ?? "Invalid phone number")
                        .font(.custom(AppFont.medium.rawValue, size: 12))
                        .foregroundStyle(ThemeColor.red.color)
                        .padding(.leading)
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            CountryPickerView(countries: countries, selectedCountry: $selectedCountry)
        }
        .onChange(of: selectedCountry) { _, newValue in
            formatNumber(phoneNumber)
        }
    }
    
    private func validate() {
        let fullNumber = selectedCountry.dialCode + phoneNumber
        
        do {
            _ = try phoneNumberKit.parse(fullNumber)
            isValid = true
        } catch {
            isValid = false
        }
    }
}

struct CountryPickerView: View {
    let countries: [Country]
    @Binding var selectedCountry: Country
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredCountries: [Country] {
        if searchText.isEmpty { return countries }
        
        return countries.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.dialCode.contains(searchText) ||
            $0.code.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredCountries, id: \.code) { country in
                Button {
                    selectedCountry = country
                    dismiss()
                } label: {
                    HStack {
                        Text(country.flag)
                        Text(country.name)
                            .appFont(.medium, size: 16)
                            .foregroundStyle(ThemeColor.text.color)
                        
                        Spacer()
                        
                        Text(country.dialCode)
                            .appFont(.semibold, size: 14)
                            .foregroundStyle(ThemeColor.textSecondary.color)
                    }
                }
            }
            .navigationTitle("Select your country")
            .searchable(text: $searchText)
        }
    }
}
